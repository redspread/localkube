# Deprecation
**This version of localkube is deprecated.**

The localkube project has been donated to be part of minikube where it is actively maintained. All new development can be found at https://github.com/kubernetes/minikube/tree/master/pkg/localkube

# ⚡ localkube ⚡ 
[![Build Status](https://travis-ci.org/redspread/localkube.svg?branch=master)](https://travis-ci.org/redspread/localkube)

`localkube` is the easiest way to use Kubernetes. It provides a Kubernetes cluster configured to run locally and optimized for rapid development. 

The environment is intended to be used with Kubernetes development tool [spread](https://github.com/redspread/spread). 

`localkube` is a full Kubernetes 1.2 cluster, and has everything you need for a cluster in regards to networking (proxy, DNS, etc). Some more highlights:
- Single executable
- Single container
- Single process
- One command to start with `spread`

It's great for:

- Playing around with Kubernetes without having to set up a cluster on GCP or AWS
- Offline and rapid development with Kubernetes

###Requirements
- [spread](https://github.com/redspread/spread#installation)
- [kubectl](https://cloud.google.com/container-engine/docs/before-you-begin#install_kubectl)
- Make sure [Docker](https://docs.docker.com/mac/) is set up correctly, including starting `docker-machine` to bring up a VM [1]

###Getting started

- Run `spread cluster start` to start localkube
- Sanity check: `kubectl cluster-info` [2]

###Suggested workflow
- `docker build` the image that you want to work with [2]
- Create Kubernetes objects that use the image build above
- Run `spread build .` to deploy to cluster [3]
- Iterate on your application, updating image and objects running `spread build .` each time you want to deploy changes
- To preview changes, grab the IP of your docker daemon and use `kubectl describe services/'SERVICE-NAME'` for the `NodePort`, then put the `IP:NodePort` in your browser
- When finished, run `spread cluster stop` to stop localkube

[1] For now, we recommend everyone use a VM when working with `localkube`  
[2] There will be a delay in returning info the first time you start localkube, as the Weave networking container needs to download. This pause will be fixed in future releases.  
[3] `spread` will soon integrate building ([#59](https://github.com/redspread/spread/issues/59))    
[4] Since `localkube` shares a Docker daemon with your host, there is no need to push images :)

###Developing on localkube

For those interested in contributing to development, this will compile localkube executable, build an image with it inside, and run a container with the build image.

The `docker` command should be setup for the Docker daemon you want to run the cluster with.

**Linux**
```bash
make run-image
```

**OS X/Windows**
```bash
make docker-build run-image
```

The apiserver will run on port 8080 of the Docker host.

###FAQ

**Why use a local Kubernetes cluster in the first place?**

Setting up a remote Kubernetes cluster takes too long, and you can't develop and test on a Kubernetes cluster offline with a remote cluster.

**Why not use `hyperkube` or `monokube` for local dev?**

We built localkube to integrate with `spread` for an interactive workflow when developing with Kubernetes. localkube is built as a full Kubernetes 1.2 cluster, has pod networking set up with Weave, and uses `spread` for a rapid development workflow.
