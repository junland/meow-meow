IMAGE_NAME := "builder:latest"
TARGET_ARCH := "x86_64"

.PHONY: source
source:
	rm -rf sources/*.tar*
	wget -nv -i sources/SOURCELIST.txt -P sources/

.PHONY: bootstrap-0
bootstrap-0: is_container
	./bootstrap -s0 -a $(TARGET_ARCH) 2>&1 | tee _stage0-log.txt

.PHONY: bootstrap-1
bootstrap-1: is_container
	./bootstrap -s1 -a $(TARGET_ARCH) 2>&1 | tee _stage1-log.txt

# Add a target that will check to make sure that we are running in a container
.PHONY: is_container
is_container:
	@if [ ! -f /.dockerenv ]; then \
		echo "This target must be run inside a container"; \
		exit 1; \
	fi
