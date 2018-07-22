#!/bin/bash

set -euo pipefail

if [[ $# -lt 3 ]]; then
cat << _HELP_
Usage: $0 [imagefile] [size] [tree/tar]...

Example: $0 sdcard.image 4G fs/ data.tar.gz
_HELP_
fi

image="${1}"
size="${2}"
shift
shift

echo
echo ":: >> >> >> >> >> >> >> >> >>"
echo ":: >> Create rpi3 sdcard image"

echo ":: Create ${size} image ${image}"
rm -f "${image}" || :
qemu-img create -f raw "${image}" "${size}"
zcat tinkerboard.boot.gz | dd if=/dev/stdin of="${image}" conv=nocreat,notrunc

echo ":: Partition ${image}"
parted --script \
  "${image}" \
  mklabel msdos \
  mkpart primary fat32 4MB 512MB \
  mkpart primary ext4 512MiB 100% \
  set 1 boot on

echo ":: Setup block devices"
lodev=$(losetup --show --find "${image}")
kpartx -a "${lodev}"
lop1=/dev/mapper/$(lsblk -J -O ${lodev}| jq -r '.blockdevices[]|.children[]|.name'|grep 'p1$')
lop2=/dev/mapper/$(lsblk -J -O ${lodev}| jq -r '.blockdevices[]|.children[]|.name'|grep 'p2$')

echo ":: Format disks"
mkfs.vfat -F 16 -n boot "${lop1}"
mke2fs -t ext4 -e panic -L root -m 1 "${lop2}"
tune2fs -c 1 -C 1 -i 1d -o discard,journal_data_ordered "${lop2}"

echo ":: Copying data"
mount "${lop2}" /mnt/
mkdir /mnt/boot
mkdir /mnt/boot/firmware
mount "${lop1}" /mnt/boot/firmware

for tree in "$@"; do
  if [[ -d "${tree}" ]]; then
    tar -cSp -C "${tree}" . | tar -xSsp -C /mnt || :
  else
    case ${tree} in
      *.tar)
        cat "${tree}" | tar -xSsp -C /mnt || :
        ;;
      *.tar.gz)
        cat "${tree}" | tar -xzSsp -C /mnt || :
        ;;
      *)
        echo "Unknown source tree file ${tree}"
        ;;
    esac
  fi
done

echo ":: Making the system bootable"
cat >> /mnt/etc/fstab << _FSTAB_
LABEL=root  /              ext4  defaults,noatime,nodiratime,commit=600,errors=panic 1 1
LABEL=boot  /boot/firmware vfat  defaults        0 0
tmpfs       /tmp           tmpfs defaults,nosuid 0 0
_FSTAB_

echo ":: Cleanup"

umount -fl "${lop1}"  || :
umount -fl "${lop2}"  || :
kpartx -d "${lodev}"  || :
losetup -d "${lodev}" || :

echo ":: << Create rpi3 sdcard image"
echo ":: << << << << << << << << <<"
echo
