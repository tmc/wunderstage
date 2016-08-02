all: images

export PATH := $(PWD)/bin:$(PATH)

CLUSTER_NAME ?= wunderstage-2

# status lookups
HAS_K8SCLUSTER := $(shell kubectl cluster-info > /dev/null;)

.PHONY: stage0
stage0: cluster-init

.PHONY: stage1
stage1: install-deis


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

.PHONY: install-deis
install-deis: bin/helmc
	helmc target
	helmc repo add deis https://github.com/deis/charts
	helmc fetch deis/workflow-v2.2.0
	helmc generate -x manifests workflow-v2.2.0
	helmc install workflow-v2.2.0

bin/helmc:
	curl -sSL https://get.helm.sh | bash
	mv ./helmc ./bin/helmc

.PHONY: deis-status
deis-status:
	kubectl --namespace=deis get po
	kubectl --namespace=deis describe svc deis-router | grep LoadBalancer
