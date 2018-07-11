FROM ubuntu:18.04

# install the base packages
RUN apt-get update && \
    apt-get dist-upgrade -f -y && \
    apt full-upgrade -f -y && \
    apt-get install -f -y gpg gnupg2 gnupg-utils gettext-base

# add tools
COPY secret-env /usr/local/bin/secret-env
COPY target/cloud-merge /usr/local/bin/cloud-merge
COPY cloud-init-nocloud.sh /usr/local/bin/cloud-init-nocloud
