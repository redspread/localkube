mkfile_dir := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

GO ?= go
GOFMT ?= gofmt -s
GOLINT ?= golint
GODEP ?= godep
DOCKER ?= docker

BUILDER ?=

GOFILES := find . -name '*.go' -not -path "./vendor/*"
GOOS := $(shell go list -f '{{context.GOOS}}')

GOBUILD_LDFLAGS ?= --ldflags '-extldflags "-static" --s -w'
GOBUILD_FLAGS ?= -i -v

PKG ?= rsprd.com/localkube
EXEC_PKG := $(PKG)/cmd/localkube
DOCKER_DIR := /go/src/$(PKG)

MNT_ROOT ?= -v "/:/rootfs:ro"
MNT_SYS ?= -v "/sys:/sys:rw"
MNT_DOCKER_LIB ?= -v "/var/lib/docker:/var/lib/docker" -v "/mnt/sda1/var/lib/docker:/mnt/sda1/var/lib/docker"
MNT_KUBELET_LIB ?= -v "/var/lib/kubelet:/var/lib/kubelet"
MNT_RUN ?= -v "/var/run:/var/run:rw"

MNT_REPO ?= -v "$(mkfile_dir):$(DOCKER_DIR)"

DOCKER_OPTS ?=
DOCKER_OPTS_KUBELET_VOLS ?= $(MNT_ROOT) $(MNT_SYS) $(MNT_DOCKER_LIB) $(MNT_KUBELET_LIB) $(MNT_RUN)
DOCKER_RUN_OPTS ?= $(DOCKER_OPTS_KUBELET_VOLS) --privileged="true" --net="host" --pid="host"

# image data
ORG ?= redspreadapps
NAME ?= localkube
TAG ?= latest

DOCKER_IMAGE_NAME = "$(ORG)/$(NAME):$(TAG)"
DOCKER_DEV_IMAGE ?= "golang:1.6"

.PHONY: all
all: clean validate build build-image integration

.PHONY: validate
validate: checkgofmt

.PHONY: integration
integration: build-image
	./test/mattermost-demo.sh

.PHONY: build
build: build/localkube-$(GOOS)

.PHONY: docker-build
docker-build: validate
	mkdir build
	$(DOCKER) run -w $(DOCKER_DIR) $(DOCKER_OPTS) $(MNT_REPO) $(DOCKER_DEV_IMAGE) make build

.PHONY: clean
clean:
	rm -rf ./build

build/localkube-$(GOOS):
	$(GO) build -o $@ $(GOBUILD_FLAGS) $(GOBUILD_LDFLAGS) $(EXEC_PKG)

.PHONY: build-image
build-image: context
	$(DOCKER) build $(DOCKER_OPTS) -t $(DOCKER_IMAGE_NAME) ./build/context

.PHONY: run-image
run-image: build-image
	$(DOCKER) run -it $(DOCKER_OPTS) $(DOCKER_RUN_OPTS) $(DOCKER_IMAGE_NAME)

.PHONY: push-image
push-image: build-image
	$(DOCKER) $(DOCKER_OPTS) push $(DOCKER_IMAGE_NAME)

.PHONY: push-latest
push-latest: build-image
	$(DOCKER) $(DOCKER_OPTS) tag -f $(DOCKER_IMAGE_NAME) $(ORG)/$(NAME):latest
	$(DOCKER) $(DOCKER_OPTS) push $(ORG)/$(NAME):latest

.PHONY: context
context: build/localkube-linux
	rm -rf ./build/context
	cp -r ./image ./build/context
	cp ./build/localkube-linux ./build/context
	chmod +x ./build/context/localkube-linux


.PHONY: checkgofmt
checkgofmt:
	# get all go files and run go fmt on them
	@files=$$($(GOFILES) | xargs $(GOFMT) -l); if [ -n "$$files" ]; then \
		  echo "Error: '$(GOFMT)' needs to be run on:"; \
		  echo "$${files}"; \
		  exit 1; \
		  fi;

.PHONY: godep
godep:
	go get -u -v github.com/tools/godep
	@echo "Recalculating godeps, removing Godeps and vendor if not canceled in 5 seconds"
	@sleep 5
	rm -rf Godeps vendor
	GO15VENDOREXPERIMENT="1" godep save -v . ./cmd/localkube ./pkg/...

	@echo "Applying hack to prevent golang.org/x/net/trace from running init block."
	@echo "This conflicts with a duplicate import by etcd"
	git checkout 37c71fd vendor/golang.org/x/net/trace/trace.go
