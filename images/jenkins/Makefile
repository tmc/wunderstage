PROJECT ?= $(shell gcloud config list --format 'value(core.project)' 2>/dev/null)
REGISTRY ?= gcr.io

all: image

image:
	docker build -t jenkins .

release: image
	docker tag -f jenkins $(REGISTRY)/$(PROJECT)/jenkins
	gcloud docker -- push $(REGISTRY)/$(PROJECT)/jenkins
