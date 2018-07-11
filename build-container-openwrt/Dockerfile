FROM home-network-builder

# install the base packages
RUN apt-get update && \
    apt-get dist-upgrade -f -y && \
    apt full-upgrade -f -y && \
    apt-get install -f -y \
      p7zip \
      time unzip file wget rsync git subversion gawk \
      build-essential g++ python \
      libncurses5-dev zlib1g-dev libssl-dev

# arguments only apply to the later download
ARG VERSION
ARG PLATFORM
ARG TYPE=generic

# install the lede image builder
RUN if [ "${VERSION}" = "snapshot" ]; then \
      wget -O /tmp/imagebuilder.tar.xz https://downloads.openwrt.org/snapshots/targets/${PLATFORM}/${TYPE}/openwrt-imagebuilder-${PLATFORM}-${TYPE}.Linux-x86_64.tar.xz; \
    else \
      wget -O /tmp/imagebuilder.tar.xz https://downloads.openwrt.org/releases/${VERSION}/targets/${PLATFORM}/${TYPE}/lede-imagebuilder-${VERSION}-${PLATFORM}-${TYPE}.Linux-x86_64.tar.xz; \
    fi && \
    mkdir /srv/builder/ && \
    tar -xJf /tmp/imagebuilder.tar.xz -C /srv/builder/ --strip-components=1 && \
    rm /tmp/imagebuilder.tar.xz
