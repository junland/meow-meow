IMAGE_NAME := "builder:latest"
TARGET_ARCH := "x86_64"

bootstrap-0: is_container
	./bootstrap -s0 -a $(TARGET_ARCH) 2>&1 | tee stage0-log.txt

is_container:
ifeq ($(shell cat /proc/1/cgroup | grep docker),)
        $(error "This script must be run inside a container")
endif

container-image: is_container
	docker build -t $(IMAGE_NAME) .

container-run: is_container
	docker run -it --rm $(IMAGE_NAME) /bin/bash

source:
	wget -i sources/SOURCELIST.txt -P sources/