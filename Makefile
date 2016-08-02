all: images

CLUSTER_NAME ?= wunderstage-2

.PHONY: images
images:
	$(MAKE) -C images images

.PHONY: release
release: images
	$(MAKE) -C images release

.PHONY: deploy
deploy: release cluster-init


.PHONY: cluster-init
	gcloud clusters create $(CLUSTER_NAME) --zone "us-west1-b" --machine-type "n1-standard-1" --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly" --num-nodes "3" --network "default" --enable-cloud-logging --enable-cloud-monitoring


