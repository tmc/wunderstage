all: images

export PATH := $(PWD)/bin:$(PATH)

CLUSTER_NAME ?= wunderstage-2
WORKFLOW_VERSION ?= v2.3.0
PROJECT ?= $(shell gcloud config list --format 'value(core.project)' 2>/dev/null)
DEIS_IP := $(shell sh -c 'kubectl --namespace=deis describe svc deis-router |grep "LoadBalancer Ingress" | cut -f2')
DEIS_ENDPOINT := http://deis.$(DEIS_IP).nip.io

# status lookups
HAS_K8SCLUSTER := $(shell kubectl cluster-info > /dev/null;)

.PHONY: stage0
stage0: cluster-init

.PHONY: stage1
stage1: deis-install

.PHONY: stage2
stage2: jenkins-install


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
	helmc fetch deis/workflow-$(WORKFLOW_VERSION)
	helmc generate -x manifests workflow-$(WORKFLOW_VERSION)
	helmc install workflow-$(WORKFLOW_VERSION)

$(HOME)/.ssh/id_rsa-deis.pub:
	ssh-keygen -t rsa -N "" -f $(HOME)/.ssh/id_rsa-deis

secrets/.deispw:
	dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 | tr -d '\n' > $@

secrets/.deispw-jenkins:
	dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 | tr -d '\n' > $@

.PHONY: deis-status
deis-status:
	kubectl --namespace=deis get po
	kubectl --namespace=deis describe svc deis-router | grep LoadBalancer

charts/jenkins/jenkins-deis-conf.json: bin/deis secrets/.deispw secrets/.deispw-jenkins $(HOME)/.ssh/id_rsa-deis.pub
	deis keys:add ~/.ssh/id_rsa-deis.pub
	deis register $(DEIS_ENDPOINT) --username=admin --password=$(shell cat secrets/.deispw) --email=admin@foobar.com
	DEIS_PROFILE=jenkins deis register $(DEIS_ENDPOINT) --username=jenkins --password=$(shell cat secrets/.deispw-jenkins) --email=ci@foobar.com
	cp ~/.deis/jenkins.json $@

.gopath:
	go env GOPATH | cut -d: -f1 > .gopath

bin/helm:
	curl -L https://github.com/kubernetes/helm/releases/download/v2.0.0-alpha.3/helm-v2.0.0-alpha.3-linux-amd64.tar | tar -C bin -xvf - 
	mv bin/linux-amd64/* bin/
	rmdir bin/linux-amd64

secrets/htpasswd: secrets/.deispw-jenkins
	echo "jenkins:$(shell cat secrets/.deispw-jenkins)" > $@

secrets/key.pem:
	cd secrets && openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -subj "/C=US/ST=CA/L=SF/O=Ops/CN=ci.$(DEIS_IP)" -nodes

secrets/dhparam:
	openssl dhparam -out secrets/dhparam 2048 -dsaparam


.PHONY: jenkins-install
jenkins-install: bin/helm secrets/key.pem secrets/htpasswd secrets/dhparam charts/jenkins/jenkins-deis-conf.json
	helm version
	helm init
	sleep 4
	cp secrets/* charts/jenkins/
	helm install --namespace=ci --set PROJECT=$(PROJECT),deisBuilder=deis-builder.$(DEIS_IP).nip.io -n ci-1 charts/jenkins
    echo "running `kubectl --namespace=ci describe svc ci-1-proxy` to inspect service`"
    kubectl --namespace=ci describe svc ci-1-proxy` to inspect service
    echo "sleeping 10s then running again"
    sleep 10
	kubectl --namespace=ci describe svc ci-1-proxy` to inspect service
