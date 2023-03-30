.ONESHELL:

OLD_SHELL := $(SHELL)
SHELL = $(warning Building $@$(if $<, (from $<))$(if $?, ($? newer)))$(OLD_SHELL)

repo_path := $(patsubst %/,%,$(dir $(abspath "$(MAKEFILE_LIST)")))
image_url := https://updates.volumio.org/pi/volumio/3.435/Volumio-3.435-2023-03-06-pi.zip
image_file := $(notdir $(image_url))

vpath Dockerfile $(repo_path)/container

image: $(image_file:.zip=.img)
	echo "$<"

%.img: %.zip
	unzip $<

$(image_file):
	curl -Lo $(image_file) $(image_url)

