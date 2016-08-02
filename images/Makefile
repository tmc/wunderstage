all: images

.PHONY: images
images:
	$(MAKE) -C jenkins image

.PHONY: release
release: images
	$(MAKE) -C jenkins release
