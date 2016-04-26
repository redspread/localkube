package localkube

import (
	"os"
	"time"

	kubelet "k8s.io/kubernetes/cmd/kubelet/app"
	"k8s.io/kubernetes/cmd/kubelet/app/options"
)

const (
	KubeletName = "kubelet"
)

var (
	WeaveProxySock = "unix:///var/run/weave/weave.sock"
	KubeletStop    chan struct{}
)

func NewKubeletServer(clusterDomain, clusterDNS string) Server {
	return &SimpleServer{
		ComponentName: KubeletName,
		StartupFn:     StartKubeletServer(clusterDomain, clusterDNS),
		ShutdownFn: func() {
			close(KubeletStop)
		},
	}
}

func StartKubeletServer(clusterDomain, clusterDNS string) func() {
	KubeletStop = make(chan struct{})
	config := options.NewKubeletServer()

	// master details
	config.APIServerList = []string{APIServerURL}

	// Docker
	config.Containerized = *containerized
	config.DockerEndpoint = WeaveProxySock

	// Networking
	config.ClusterDomain = clusterDomain
	config.ClusterDNS = clusterDNS

	// use hosts resolver config
	config.ResolverConfig = "/rootfs/etc/resolv.conf"

	schedFn := func() error {
		return kubelet.Run(config, nil)
	}

	return func() {
		go until(schedFn, os.Stdout, KubeletName, 200*time.Millisecond, KubeletStop)
	}
}
