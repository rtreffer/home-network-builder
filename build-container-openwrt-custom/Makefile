PLATFORM ?= ar71xx
TYPE ?= generic

container-openwrt-builder-custom-$(PLATFORM)-$(TYPE): target/openwrt-imagebuilder-$(PLATFORM)-$(TYPE).Linux-x86_64.tar.xz
	docker build -t openwrt-builder-custom-$(PLATFORM)-$(TYPE) --build-arg PLATFORM=$(PLATFORM) .

target/openwrt-imagebuilder-$(PLATFORM)-$(TYPE).Linux-x86_64.tar.xz: openwrt/bin/targets/$(PLATFORM)/$(TYPE)/openwrt-imagebuilder-$(PLATFORM)-$(TYPE).Linux-x86_64.tar.xz
	mkdir -p target
	cp $< $@

openwrt/bin/targets/$(PLATFORM)/$(TYPE)/openwrt-imagebuilder-$(PLATFORM)-$(TYPE).Linux-x86_64.tar.xz:
