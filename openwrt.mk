BASE_FOLDER ?=$(abspath $(dir $(firstword $(MAKEFILE_LIST))))
OPENWRT_BUILDER_FOLDER ?=$(abspath $(dir $(lastword $(MAKEFILE_LIST))))
OPENWRT_DOWNLOAD_FOLDER ?=$(OPENWRT_BUILDER_FOLDER)/tmp/
OPENWRT_BUILDSCRIPT="set -eux -o pipefail ; mkdir -p /srv/overlay ; rsync -KraulSpalt /srv/overlay-base/* /srv/overlay/ ; rsync -KraulSpalt /srv/overlay-node/* /srv/overlay/ ; cd /srv/builder/ && /usr/local/bin/secret-env /srv/secrets/env.enc /srv/overlay/etc/secrets/env make image PROFILE=\$${PROFILE} EXTRA_IMAGE_NAME=\$${NODE} BIN_DIR=/srv/target/ FILES=/srv/overlay/ PACKAGES=\"\$${BASE_PACKAGES} \$${BASE_PACKAGES_VERSION} \$${PACKAGES} \$${PACKAGES_VERSION}\" ; chown \$${TARGET_UID} /srv/target/*\$${NODE}*"

$(OPENWRT_DOWNLOAD_FOLDER)/%:
	mkdir -p "$@"

container:
	make -C build/build-container container

# build-container requires 3 arguments:
# 1. the openwrt version
# 2. the architecture
# 3. the sub type
define openwrt-build-container
container-$(1)-$(2)-$(3): container
	docker build -t openwrt-builder-$(1)-$(2)-$(3) --build-arg VERSION=$(1) --build-arg PLATFORM=$(2) --build-arg TYPE=$(3) -f $(OPENWRT_BUILDER_FOLDER)/build-container-openwrt/Dockerfile $(OPENWRT_BUILDER_FOLDER)/build-container-openwrt
.PHONY: container-$(1)-$(2)-$(3)
endef

# build-node requires arguments:
# 1. the node
# 2. the openwrt version
# 3. the architecture
# 4. the type
# 5. the profile
define build-node
$(1): container-$(2)-$(3)-$(4) $(OPENWRT_DOWNLOAD_FOLDER)/$(2)-$(3)-$(4)
	docker run --rm -t -i \
		-e TARGET_UID=$(shell id -u) \
		-v $(BASE_FOLDER)/target:/srv/target \
		-v $(BASE_FOLDER)/secrets:/srv/secrets \
		--env-file $(BASE_FOLDER)/openwrt-all/env \
		--env-file $(BASE_FOLDER)/openwrt-all/env-$(2) \
		--env-file $(BASE_FOLDER)/openwrt-$(1)/env \
		--env-file $(BASE_FOLDER)/openwrt-$(1)/env-$(2) \
		-e PROFILE=$(5) \
		-v $(BASE_FOLDER)/openwrt-all/overlay:/srv/overlay-base \
		-v $(BASE_FOLDER)/openwrt-$(1)/overlay:/srv/overlay-node \
		--tmpfs /srv/overlay/etc/secrets \
		-v $(OPENWRT_DOWNLOAD_FOLDER)/$(2)-$(3)-$(4):/srv/builder/dl \
	openwrt-builder-$(2)-$(3)-$(4) \
	bash -c $$(OPENWRT_BUILDSCRIPT)
.PHONY: $(1)
nodes: $(1)
endef

