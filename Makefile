all: images

export PATH := $(PWD)/bin:$(PATH)

CLUSTER_NAME ?= wunderstage-2
DEIS_IP := $(shell sh -c 'kubectl --namespace=deis describe svc deis-router |grep "LoadBalancer Ingress" | cut -f2')
DEIS_ENDPOINT := http://deis.$(DEIS_IP).nip.io

# status lookups
HAS_K8SCLUSTER := $(shell kubectl cluster-info > /dev/null;)

.PHONY: stage0
stage0: cluster-init

.PHONY: stage1
stage1: deis-install


.PHONY: images
images:
	$(MAKE) -C images images

.PHONY: release
release: images
	$(MAKE) -C images release

.PHONY: deploy
deploy: release

.PHONY: cluster-init
	gcloud clusters create $(CLUSTER_NAME) --zone "us-west1-b" --machine-type "n1-standard-1" --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly" --num-nodes "3" --network "default" --enable-cloud-logging --enable-cloud-monitoring

bin/helmc:
	curl -sSL https://get.helm.sh | bash
	mv ./helmc ./bin/helmc

bin/deis:
	curl -sSL http://deis.io/deis-cli/install-v2.sh | bash
	mv ./deis ./bin/deis

.PHONY: deis-install
deis-install: bin/helmc
	helmc target
	helmc repo add deis https://github.com/deis/charts
	helmc fetch deis/workflow-v2.2.0
	helmc generate -x manifests workflow-v2.2.0
	helmc install workflow-v2.2.0

$(HOME)/.ssh/id_rsa-deis.pub:
	ssh-keygen -t rsa -N "" -f $(HOME)/.ssh/id_rsa-deis

.PHONY: deis-key
deis-key: $(HOME)/.ssh/id_rsa-deis.pub

.deispw:
	dd if=/dev/random bs=1 count=32 2>/dev/null | base64 | tr -d '\n' > .deispw
	deis register $(DEIS_ENDPOINT) --username=admin --password=$(shell cat .deispw) --email=admin@foobar.com

.PHONY: deis-setup
deis-setup: .deispw deis-key
	deis keys:add ~/.ssh/id_rsa-deis.pub

.PHONY: deis-status
deis-status:
	kubectl --namespace=deis get po
	kubectl --namespace=deis describe svc deis-router | grep LoadBalancer
