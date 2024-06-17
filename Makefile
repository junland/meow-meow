bootstrap-0: is_container
	./bootstrap -s0 2>&1 | tee stage0-log.txt

is_container:
ifeq ($(shell cat /proc/1/cgroup | grep docker),)
        $(error "This script must be run inside a container")
endif