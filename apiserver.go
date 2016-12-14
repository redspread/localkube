package localkube

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"net"
	"os"
	"strings"
	"time"

	apiserver "k8s.io/kubernetes/cmd/kube-apiserver/app"
	"k8s.io/kubernetes/cmd/kube-apiserver/app/options"
	etcdstorage "k8s.io/kubernetes/pkg/storage/etcd"
)

const (
	APIServerName = "apiserver"
	APIServerHost = "0.0.0.0"
	APIServerPort = 8080
)

var (
	APIServerURL   string
	ServiceIPRange = "10.1.30.0/24"
	APIServerStop  chan struct{}
)

func init() {
	APIServerURL = fmt.Sprintf("http://%s:%d", APIServerHost, APIServerPort)
	if ipRange := os.Getenv("SERVICE_IP_RANGE"); len(ipRange) != 0 {
		ServiceIPRange = ipRange
	}
}

func NewAPIServer() Server {
	return &SimpleServer{
		ComponentName: APIServerName,
		StartupFn:     StartAPIServer,
		ShutdownFn: func() {
			close(APIServerStop)
		},
	}
}

func MakeRSAKey(privateKeyPath string) error {
	privateKey, err := rsa.GenerateKey(rand.Reader, 1024)
	if err != nil {
		return err
	}

	// generate and write private key as PEM
	privateKeyFile, err := os.Create(privateKeyPath)
	defer privateKeyFile.Close()
	if err != nil {
		return err
	}
	privateKeyPEM := &pem.Block{Type: "RSA PRIVATE KEY", Bytes: x509.MarshalPKCS1PrivateKey(privateKey)}
	if err := pem.Encode(privateKeyFile, privateKeyPEM); err != nil {
		return err
	}
	return nil
}

func StartAPIServer() {
	APIServerStop = make(chan struct{})
	config := options.NewAPIServer()

	// use host/port from vars
	config.InsecureBindAddress = net.ParseIP(APIServerHost)
	config.InsecurePort = APIServerPort

	// use localkube etcd
	config.EtcdConfig = etcdstorage.EtcdConfig{
		ServerList: KubeEtcdClientURLs,
	}

	// set Service IP range
	_, ipnet, err := net.ParseCIDR(ServiceIPRange)
	if err != nil {
		panic(err)
	}
	config.ServiceClusterIPRange = *ipnet

	// defaults from apiserver command
	config.EnableProfiling = true
	config.EnableWatchCache = true
	config.MinRequestTimeout = 1800

	MakeRSAKey("/tmp/kube-serviceaccount.key")
	config.ServiceAccountKeyFile = "/tmp/kube-serviceaccount.key"
	config.ServiceAccountLookup = false
	config.AdmissionControl = "NamespaceLifecycle,LimitRanger,SecurityContextDeny,ServiceAccount,ResourceQuota"

	fn := func() error {
		return apiserver.Run(config)
	}

	// start API server in it's own goroutine
	go until(fn, os.Stdout, APIServerName, 200*time.Millisecond, SchedulerStop)
}

// notFoundErr returns true if the passed error is an API server object not found error
func notFoundErr(err error) bool {
	if err == nil {
		return false
	}
	return strings.HasSuffix(err.Error(), "not found")
}
