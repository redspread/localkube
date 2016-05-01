package localkube

import (
	"fmt"
	"net"
	"os"
	"strings"
	"time"

	"k8s.io/kubernetes/pkg/storage/storagebackend"

	apiserver "k8s.io/kubernetes/cmd/kube-apiserver/app"
	"k8s.io/kubernetes/cmd/kube-apiserver/app/options"
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

func StartAPIServer() {
	APIServerStop = make(chan struct{})
	config := options.NewAPIServer()

	// use host/port from vars
	config.InsecureBindAddress = net.ParseIP(APIServerHost)
	config.InsecurePort = APIServerPort

	// use localkube etcd
	config.StorageConfig = storagebackend.Config{ServerList: KubeEtcdClientURLs}

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
