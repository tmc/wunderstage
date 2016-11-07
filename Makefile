all: images

export PATH := $(PWD)/bin:$(PATH)

CLUSTER_NAME ?= wunderstage-1
WORKFLOW_VERSION ?= v2.8.0
PROJECT ?= $(shell gcloud config list --format 'value(core.project)' 2>/dev/null)
DEIS_IP := $(shell sh -c 'kubectl --namespace=deis describe svc deis-router 2>&1|grep "LoadBalancer Ingress" | cut -f2')
DEIS_ENDPOINT := http://deis.$(DEIS_IP).nip.io
HELM_VERSION ?= v2.0.0-rc.2

# if using gke
GKE_ZONE ?= us-west1-b
GKE_MACHINE_TYPE ?= n1-standard-1

# status lookups
HAS_K8SCLUSTER := $(shell kubectl cluster-info > /dev/null;)

.PHONY: stage0
stage0: cluster-init

.PHONY: stage1
stage1: images-release

.PHONY: stage2
stage2: deis-install

.PHONY: stage3
stage4: jenkins-install

.PHONY: images
images:
	$(MAKE) -C images images

.PHONY: images-release
images-release: images
	$(MAKE) -C images release

.PHONY: deploy
deploy: release

.PHONY: cluster-init
cluster-init:
	gcloud container clusters create $(CLUSTER_NAME) --zone $(GKE_ZONE) --machine-type $(GKE_MACHINE_TYPE) --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly" --num-nodes "3" --network "default" --enable-cloud-logging --enable-cloud-monitoring

bin/deis:
	curl -sSL http://deis.io/deis-cli/install-v2.sh | bash
	mv ./deis ./bin/deis

.PHONY: deis-install
deis-install: bin/helm
	bin/helm init
	echo 'sleeping 10s to wait for tiller'
	sleep 1
	bin/helm repo add deis https://charts.deis.com/workflow
	bin/helm install --namespace=deis -n deis deis/workflow --version=$(WORKFLOW_VERSION) --namespace=deis -f values.yaml

.PHONY: deis-status
deis-status:
	kubectl --namespace=deis get po
	kubectl --namespace=deis describe svc deis-router | grep LoadBalancer

bin/helm:
	curl -sSL http://storage.googleapis.com/kubernetes-helm/helm-$(HELM_VERSION)-linux-amd64.tar.gz | tar xzvf -
	mv linux-amd64/* bin/
	rmdir linux-amd64


## secrets 

secrets/id_rsa-deis.pub:
	ssh-keygen -t rsa -N "" -f secrets/id_rsa-deis

secrets/.deispw:
	dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 | tr -d '\n' > $@

secrets/.deispw-jenkins:
	dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 | tr -d '\n' > $@

charts/jenkins/jenkins-deis-conf.json: bin/deis secrets/.deispw secrets/.deispw-jenkins secrets/id_rsa-deis.pub
	deis register $(DEIS_ENDPOINT) --username=admin --password=$(shell cat secrets/.deispw) --email=admin@foobar.com
	DEIS_PROFILE=jenkins deis register $(DEIS_ENDPOINT) --username=jenkins --password=$(shell cat secrets/.deispw-jenkins) --email=ci@foobar.com
	DEIS_PROFILE=jenkins deis keys:add secrets/id_rsa-deis.pub
	cp ~/.deis/jenkins.json $@

secrets/htpasswd: secrets/.deispw-jenkins
	echo "jenkins:$(shell cat secrets/.deispw-jenkins | openssl passwd -stdin)" > secrets/htpasswd

secrets/key.pem:
	cd secrets && openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -subj "/C=US/ST=CA/L=SF/O=Ops/CN=ci.$(DEIS_IP)" -nodes

secrets/dhparam:
	openssl dhparam -out secrets/dhparam 2048 -dsaparam


.PHONY: jenkins-install
jenkins-install: bin/helm secrets/key.pem secrets/htpasswd secrets/dhparam charts/jenkins/jenkins-deis-conf.json
	 cp secrets/* charts/jenkins/
	 helm install --namespace=ci --set PROJECT=$(PROJECT),deisBuilder=deis-builder.$(DEIS_IP).nip.io -n ci-1 charts/jenkins
	 echo "running 'kubectl --namespace=ci describe svc ci-1-proxy` to inspect service'"
	 kubectl --namespace=ci describe svc ci-1-proxy | grep Ingress
	 echo "sleeping 10s then running again"
	 sleep 10
	 kubectl --namespace=ci describe svc ci-1-proxy | grep Ingress

.PHONY: jenkins-reinstall
jenkins-reinstall:
	helm install --namespace=ci --set PROJECT=$(PROJECT),deisBuilder=deis-builder.$(DEIS_IP).nip.io -n ci-foobar charts/jenkins --debug --dry-run | sed '1,/MANIFEST:/d' | sed 's/ci-foobar/ci-1/g' | kubectl --namespace=ci apply -f -
