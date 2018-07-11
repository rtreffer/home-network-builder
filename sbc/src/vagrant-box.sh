#!/bin/bash

apt-get update
apt-get -y install \
  build-essential \
  debootstrap \
  qemu-user-static \
  qemu-utils \
  kpartx \
  parted \
  dosfstools \
  cloud-image-utils \
  jq
