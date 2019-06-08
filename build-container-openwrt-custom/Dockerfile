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
ARG PLATFORM
ARG TYPE=generic

COPY target/openwrt-imagebuilder-${PLATFORM}-${TYPE}.Linux-x86_64.tar.xz /tmp/imagebuilder.tar.xz
RUN mkdir -p /srv/builder && tar -xJf /tmp/imagebuilder.tar.xz -C /srv/builder/ --strip-components=1 && rm /tmp/imagebuilder.tar.xz
