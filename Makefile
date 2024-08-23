.ONESHELL:

# Configurations
IMAGE_URL := https://cdimage.ubuntu.com/ubuntu-core/22/stable/current/ubuntu-core-22-arm64+raspi.img.xz

# Helper variables
CACHEDIR := $(HOME)/.cache/rpi3-spotify
IMAGE_FILE := $(CACHEDIR)/$(notdir $(IMAGE_URL))
IMAGE_UNPACKED := $(basename $(IMAGE_FILE))
ROOTFS_FILE := $(IMAGE_UNPACKED:.img=.tgz)

$(warning IMAGE_URL.....: $(IMAGE_URL))
$(warning CACHEDIR......: $(CACHEDIR))
$(warning IMAGE_FILE....: $(IMAGE_FILE))
$(warning IMAGE_UNPACKED: $(IMAGE_UNPACKED))
$(warning ROOTFS_FILE...: $(ROOTFS_FILE))

# Debug printouts
OLD_SHELL := $(SHELL)
SHELL = $(warning Building $@$(if $<, (from $<))$(if $?, ($? newer)))$(OLD_SHELL)

vpath Dockerfile container

# export SUITE := buster

#rpi3-spotify.rootfs.tar:
#	mmdebstrap --variant=minbase --include=raspberrypi-archive-keyring,raspberrypi-bootloader-nokernel,raspberrypi-kernel,raspberrypi-ui-mods,python3,python3-pip,python3-setuptools $SUITE $@

.PHONY: image
image: $(ROOTFS_FILE) Dockerfile
	cp -R container/* $(CACHEDIR)
	cp /usr/bin/qemu-arm-static $(CACHEDIR)
	podman build --build-arg IMAGE="$(notdir $<)" $(CACHEDIR)

$(IMAGE_FILE): $(CACHEDIR)
	test -f "$@" || curl -Lo "$@" "$(IMAGE_URL)"

$(IMAGE_UNPACKED): $(IMAGE_FILE)
	unxz --keep --force "$<"

$(ROOTFS_FILE): $(IMAGE_UNPACKED)
	./img_to_tar "$<" "$@"

$(CACHEDIR):
	mkdir -p "$@"

