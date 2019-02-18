#!/bin/bash

set -eu -o pipefail

apt-get update
apt-get install -y --no-install-recommends gnupg
echo 'deb http://ppa.launchpad.net/rpi-distro/ppa/ubuntu bionic main' \
  > /etc/apt/sources.list.d/ubuntu-rpi.list
apt-key adv --keyserver keyserver.ubuntu.com --recv F5D7A79E01C27877
apt-get update

mkdir  /etc/flash-kernel
echo 'Raspberry Pi 3 Model B' >  /etc/flash-kernel/machine
apt-get install -y -f dosfstools rpiboot raspi3-firmware linux-image-raspi2

VERSION="1.20180924"
curl -L "https://github.com/raspberrypi/firmware/archive/${VERSION}.tar.gz" | \
  tar -xzvC /boot/firmware/ --strip-components=2 "firmware-${VERSION}/boot/"

# configure bootloader
cat > /boot/firmware/config.txt << _CONFIG_
arm_control=0x200
disable_splash=1
dtoverlay=pi3-disable-bt
dtoverlay=pi3-disable-wifi
dtparam=audio=off
enable_uart=1
gpu_mem=16

# set very low freq cpu output
gpu_freq=150
h264_freq=25
isp_freq=25
v3d_freq=25
_CONFIG_
echo 'console=serial0,115200 root=/dev/mmcblk0p2 rootfstype=ext4 fsck.repair=yes rootwait' > /boot/firmware/cmdline.txt

rm -f /boot/firmware/kernel*.img
cp /vmlinuz /boot/firmware/kernel8.img
