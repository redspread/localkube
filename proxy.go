package localkube

import (
	"os"
	"time"

	kubeproxy "k8s.io/kubernetes/cmd/kube-proxy/app"
	"k8s.io/kubernetes/cmd/kube-proxy/app/options"
	"k8s.io/kubernetes/pkg/apis/componentconfig"
	"k8s.io/kubernetes/pkg/kubelet/qos"
)

const (
	ProxyName = "proxy"
)

var (
	MasqueradeBit = int32(14)
	ProxyStop     chan struct{}
)

func NewProxyServer() Server {
	return &SimpleServer{
		ComponentName: ProxyName,
		StartupFn:     StartProxyServer,
		ShutdownFn: func() {
			close(ProxyStop)
		},
	}
}

func StartProxyServer() {
	ProxyStop = make(chan struct{})
	config := options.NewProxyConfig()

	// master details
	config.Master = APIServerURL

	// TODO: investigate why IP tables is not working
	config.Mode = componentconfig.ProxyModeUserspace

	// defaults
	oom := int32(qos.KubeProxyOOMScoreAdj)
	config.OOMScoreAdj = &oom
	config.IPTablesMasqueradeBit = &MasqueradeBit

	server, err := kubeproxy.NewProxyServerDefault(config)
	if err != nil {
		panic(err)
	}

	go until(server.Run, os.Stdout, ProxyName, 200*time.Millisecond, ProxyStop)
}
