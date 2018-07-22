container:
	make -C build/build-container container

target/tinkerboard-armbian-beta-bionic.tar.gz:
	make -C build/sbc tinkerboard-armbian-beta-bionic

target/rpi3-ubuntu-bionic-arm64.tar.gz:
	make -C build/sbc rpi3-ubuntu-bionic-arm64

# build-sbc-node requires as arguments:
# 1. node name
# 2. sbc
# 3. OS
define build-sbc-node
$(1): target/sbc-$(1)-$(2)-$(3)-sdcard.img
	
target/sbc-$(1)-$(2)-$(3)-sdcard.img: target/$(1).tar.gz target/$(2)-$(3).tar.gz
	make -C build/sbc -f Makefile.sdcard $@ NODE=$(1) SBC=$(2) OS=$(3)

target/$(1).tar.gz: sbc-$(1)/* sbc-all/* container
	mkdir -p "target/$(1)/etc/cloud/cloud.cfg.d/"
	docker run --rm -ti \
		-v $(PWD):/srv \
		-w /srv \
		--tmpfs /tmp \
		--env-file sbc-all/env \
		--env-file sbc-$(1)/env \
		home-network-builder \
		bash -c " \
		/usr/local/bin/secret-env \
			/srv/secrets/env.enc \
			/tmp/secrets.env \
			/usr/local/bin/cloud-merge \
				/tmp/user-data \
				sbc-all/* sbc-$(1)/* && \
		/usr/local/bin/cloud-init-nocloud $(1) /tmp/user-data > /srv/target/$(1)/etc/cloud/cloud.cfg.d/90_dpkg.cfg && \
		if [[ -f sbc-$(1)/netplan ]] ; then \
		  envsubst < sbc-$(1)/netplan > /srv/target/$(1)/etc/cloud/cloud.cfg.d/99_network-config.cfg ; \
		fi ; \
		tar -czf /srv/target/$(1).tar.gz -C /srv/target/$(1) etc/cloud/cloud.cfg.d/ \
		"
endef
