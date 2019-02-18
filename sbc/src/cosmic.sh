#!/bin/bash

echo
echo ":: >> >> >> >> >> >> >> >> >> >> >>"
echo ":: >> Ubuntu bionic postprocessing"

echo ":: reset fix sources"
 > /etc/apt/sources.list
cat > /etc/apt/sources.list.d/ubuntu.list <<'_EOF_'
deb http://ports.ubuntu.com/ cosmic main restricted universe multiverse
deb http://ports.ubuntu.com/ cosmic-updates main restricted universe multiverse
deb http://ports.ubuntu.com/ cosmic-security main restricted universe multiverse
_EOF_
apt-get clean
apt-get update

echo ":: updating base system"
apt-get -y dist-upgrade

echo ":: install additional software"

apt-get install -y \
  gnupg \
  sudo \
  cloud-init \
  cloud-initramfs-growroot \
  dmidecode \
  linux-firmware \
  openssh-server

# tlp recommends tlp-rdw which depends on NetworkManager
apt-get install --no-install-recommends -y tlp cpufrequtils powertop

# install ubuntu server, but without recommendations
apt-get install --no-install-recommends -y ubuntu-server

# install wireless tools
apt-get install --no-install-recommends -y iw crda rfkill wireless-regdb wireless-tools

echo ":: configure base system"

mkdir /etc/systemd/system.conf.d
systemctl disable NetworkManager
systemctl disable iscsi
systemctl disable iscsid
systemctl disable lvm2-lvmetad
systemctl enable systemd-networkd
systemctl enable systemd-timesyncd

echo ":: configure cloud-init"

# disable cloud-init netplan by default
echo 'network: {config: disabled}' > /etc/cloud/cloud.cfg.d/99_network-config.cfg

echo ":: regenerate locales"
locale-gen en_US.UTF-8

echo ":: << Ubuntu bionic postprocessing"
echo ":: << << << << << << << << << << <<"
echo
