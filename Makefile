IMAGE_NAME := "builder:latest"
TARGET_ARCH := "x86_64"
BOOTSTRAP_SH := "$(shell pwd)/bootstrap"
SHELL := /bin/bash

.PHONY: source
source:
	rm -rf sources/*.tar*
	wget -nv -i sources/SOURCELIST.txt -P sources/

.PHONY: setup
setup:
	chmod +x stages/**/*
	chmod +x utils/*
	chmod +x bootstrap

.PHONY: bootstrap-0
bootstrap-0: is_container setup
	$(BOOTSTRAP_SH) -s0 -a $(TARGET_ARCH) 2>&1 | tee _stage0-log.txt

.PHONY: bootstrap-1
bootstrap-1: is_container setup
	$(BOOTSTRAP_SH) -s1 -a $(TARGET_ARCH) 2>&1 | tee _stage1-log.txt

.PHONY: bootstrap-2
bootstrap-2: is_container setup
	$(BOOTSTRAP_SH) -s2 -a $(TARGET_ARCH) 2>&1 | tee _stage2-log.txt

# Add a target that will check to make sure that we are running in a container
.PHONY: is_container
is_container:
	@if [ ! -f /.dockerenv ]; then \
		echo "This target must be run inside a container"; \
		exit 1; \
	fi
