package localkube

import (
	"fmt"
	"net"
	"os"
	"time"

	kube2sky "rsprd.com/localkube/k2s"

	"github.com/coreos/go-etcd/etcd"
	backendetcd "github.com/skynetservices/skydns/backends/etcd"
	skydns "github.com/skynetservices/skydns/server"
	kube "k8s.io/kubernetes/pkg/api"
	kubeclient "k8s.io/kubernetes/pkg/client/unversioned"
	"k8s.io/kubernetes/pkg/util/intstr"
)

const (
	DNSName = "dns"

	DNSServiceName      = "kube-dns"
	DNSServiceNamespace = "kube-system"
)

var (
	DNSEtcdURLs = []string{"http://localhost:9090"}

	DNSEtcdDataDirectory = "/var/dns/data"
)

type DNSServer struct {
	etcd          *EtcdServer
	sky           runner
	kube2sky      func() error
	dnsServerAddr *net.UDPAddr
	clusterIP     string
	done          chan struct{}
}

func NewDNSServer(rootDomain, clusterIP, serverAddress, kubeAPIServer string) (*DNSServer, error) {
	// setup backing etcd store
	peerURLs := []string{"http://localhost:9256"}
	etcdServer, err := NewEtcd(DNSEtcdURLs, peerURLs, DNSName, DNSEtcdDataDirectory)
	if err != nil {
		return nil, err
	}

	// setup skydns
	etcdClient := etcd.NewClient(DNSEtcdURLs)
	skyConfig := &skydns.Config{
		DnsAddr: serverAddress,
		Domain:  rootDomain,
	}

	dnsAddress, err := net.ResolveUDPAddr("udp", serverAddress)
	if err != nil {
		return nil, err
	}

	skydns.SetDefaults(skyConfig)

	backend := backendetcd.NewBackend(etcdClient, &backendetcd.Config{
		Ttl:      skyConfig.Ttl,
		Priority: skyConfig.Priority,
	})
	skyServer := skydns.New(backend, skyConfig)

	// setup so prometheus doesn't run into nil
	skydns.Metrics()

	// setup kube2sky
	k2s := kube2sky.NewKube2Sky(rootDomain, DNSEtcdURLs[0], "", kubeAPIServer, 10*time.Second, 8081)

	return &DNSServer{
		etcd:          etcdServer,
		sky:           skyServer,
		kube2sky:      k2s,
		dnsServerAddr: dnsAddress,
		clusterIP:     clusterIP,
	}, nil
}

func (dns *DNSServer) Start() {
	if dns.done != nil {
		fmt.Fprint(os.Stderr, pad("DNS server already started"))
		return
	}

	dns.done = make(chan struct{})

	dns.etcd.Start()
	go until(dns.kube2sky, os.Stderr, "kube2sky", 2*time.Second, dns.done)
	go until(dns.sky.Run, os.Stderr, "skydns", 1*time.Second, dns.done)

	go func() {
		var err error
		client := kubeClient()

		meta := kube.ObjectMeta{
			Name:      DNSServiceName,
			Namespace: DNSServiceNamespace,
			Labels: map[string]string{
				"k8s-app":                       "kube-dns",
				"kubernetes.io/cluster-service": "true",
				"kubernetes.io/name":            "KubeDNS",
			},
		}

		for {
			if err != nil {
				time.Sleep(2 * time.Second)
			}

			// setup service
			if _, err = client.Services(meta.Namespace).Get(meta.Name); notFoundErr(err) {
				// create service if doesn't exist
				err = createService(client, meta, dns.clusterIP, dns.dnsServerAddr.Port)
				if err != nil {
					fmt.Printf("Failed to create Service for DNS: %v\n", err)
					continue
				}
			} else if err != nil {
				// error if cannot check for Service
				fmt.Printf("Failed to check for DNS Service existence: %v\n", err)
				continue
			}

			// setup endpoint
			if _, err = client.Endpoints(meta.Namespace).Get(meta.Name); notFoundErr(err) {
				// create endpoint if doesn't exist
				err = createEndpoint(client, meta, dns.dnsServerAddr.IP.String(), dns.dnsServerAddr.Port)
				if err == nil {
					fmt.Printf("Failed to create Endpoint for DNS: %v\n", err)
					continue
				}
			} else if err != nil {
				// error if cannot check for Endpoint
				fmt.Printf("Failed to check for DNS Endpoint existence: %v\n", err)
				continue
			}

			// setup successful
			break
		}
	}()

}

func (dns *DNSServer) Stop() {
	teardownService()

	// closing chan will prevent servers from restarting but will not kill running server
	close(dns.done)

	dns.etcd.Stop()
}

// Status is currently not support by DNSServer
func (dns *DNSServer) Status() Status {
	if dns.done == nil {
		return Stopped
	}
	return Started
}

// Name returns the servers unique name
func (DNSServer) Name() string {
	return DNSName
}

// runner starts a server returning an error if it stops.
type runner interface {
	Run() error
}

func createService(client *kubeclient.Client, meta kube.ObjectMeta, clusterIP string, dnsPort int) error {
	service := &kube.Service{
		ObjectMeta: meta,
		Spec: kube.ServiceSpec{
			ClusterIP: clusterIP,
			Ports: []kube.ServicePort{
				{
					Name:       "dns",
					Port:       53,
					TargetPort: intstr.FromInt(dnsPort),
					Protocol:   kube.ProtocolUDP,
				},
				{
					Name:       "dns-tcp",
					Port:       53,
					TargetPort: intstr.FromInt(dnsPort),
					Protocol:   kube.ProtocolTCP,
				},
			},
		},
	}

	_, err := client.Services(meta.Namespace).Create(service)
	if err != nil {
		return err
	}
	return nil
}

func createEndpoint(client *kubeclient.Client, meta kube.ObjectMeta, dnsIP string, dnsPort int) error {
	endpoints := &kube.Endpoints{
		ObjectMeta: meta,
		Subsets: []kube.EndpointSubset{
			{
				Addresses: []kube.EndpointAddress{
					{IP: dnsIP},
				},
				Ports: []kube.EndpointPort{
					{
						Name: "dns",
						Port: int32(dnsPort),
					},
					{
						Name: "dns-tcp",
						Port: int32(dnsPort),
					},
				},
			},
		},
	}

	_, err := client.Endpoints(meta.Namespace).Create(endpoints)
	if err != nil {
		return err
	}
	return nil
}

func teardownService() {
	client := kubeClient()
	client.Services(DNSServiceNamespace).Delete(DNSServiceName)
	client.Endpoints(DNSServiceNamespace).Delete(DNSServiceName)
}
