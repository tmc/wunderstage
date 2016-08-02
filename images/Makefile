all: images

.PHONY: images
images:
	$(MAKE) -C jenkins image
	$(MAKE) -C nginx-ssl-proxy image

.PHONY: release
release: images
	$(MAKE) -C jenkins release
	$(MAKE) -C nginx-ssl-proxy release
