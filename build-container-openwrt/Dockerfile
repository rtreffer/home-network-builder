FROM home-network-builder

# install the base packages
RUN apt-get update && \
    apt-get dist-upgrade -f -y && \
    apt full-upgrade -f -y && \
    apt-get install -f -y \
      p7zip zstd \
      time unzip file wget rsync git subversion gawk \
      build-essential g++ python3 \
      libncurses5-dev zlib1g-dev libssl-dev \
      python-is-python3 python3-distutils-extra

# arguments only apply to the later download
ARG VERSION
ARG PLATFORM
ARG TYPE=generic

# install the lede image builder
RUN if [ "${VERSION}" = "snapshot" ]; then \
      wget -O /tmp/imagebuilder.tar.xz https://downloads.openwrt.org/snapshots/targets/${PLATFORM}/${TYPE}/openwrt-imagebuilder-${PLATFORM}-${TYPE}.Linux-x86_64.tar.xz || \
      wget -O /tmp/imagebuilder.tar.zst https://downloads.openwrt.org/snapshots/targets/${PLATFORM}/${TYPE}/openwrt-imagebuilder-${PLATFORM}-${TYPE}.Linux-x86_64.tar.zst ; \
    else \
      wget -O /tmp/imagebuilder.tar.xz https://downloads.openwrt.org/releases/${VERSION}/targets/${PLATFORM}/${TYPE}/openwrt-imagebuilder-${VERSION}-${PLATFORM}-${TYPE}.Linux-x86_64.tar.xz || \
      wget -O /tmp/imagebuilder.tar.zst https://downloads.openwrt.org/releases/${VERSION}/targets/${PLATFORM}/${TYPE}/openwrt-imagebuilder-${VERSION}-${PLATFORM}-${TYPE}.Linux-x86_64.tar.zst ; \
    fi && \
    mkdir /srv/builder/ && \
    if [ -f /tmp/imagebuilder.tar.zst ]; then \
      tar -x --zstd -f /tmp/imagebuilder.tar.zst -C /srv/builder/ --strip-components=1 && \
      rm /tmp/imagebuilder.tar.zst ; \
    else \
      tar -xJf /tmp/imagebuilder.tar.xz -C /srv/builder/ --strip-components=1 && \
      rm /tmp/imagebuilder.tar.xz ; \
    fi
