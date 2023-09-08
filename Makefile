.ONESHELL:

OLD_SHELL := $(SHELL)
SHELL = $(warning Building $@$(if $<, (from $<))$(if $?, ($? newer)))$(OLD_SHELL)

vpath Dockerfile $(repo_path)/container

export SUITE := buster

rpi3-spotify.rootfs.tar:
	mmdebstrap --variant=minbase --include=raspberrypi-archive-keyring,raspberrypi-bootloader-nokernel,raspberrypi-kernel,raspberrypi-ui-mods,python3,python3-pip,python3-setuptools $SUITE $@


