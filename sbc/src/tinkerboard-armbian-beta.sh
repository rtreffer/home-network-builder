#!/bin/bash

echo
echo ":: >> >> >> >> >> >> >> >> >> >> >> >> >> >> >> >>"
echo ":: >> Install armbian tinkerboard tweaks and kernel"

apt-get install -y \
  linux-image-dev-rockchip \
  linux-dtb-dev-rockchip \
  linux-bionic-root-tinkerboard \
  linux-u-boot-tinkerboard-default \

systemctl disable armbian-zram-config

sed -i 's/ENABLED=.*/ENABLED=false/' /etc/default/armbian-ramlog
sed -i 's/ENABLED=.*/ENABLED=false/' /etc/default/armbian-zram-config

cat > /etc/systemd/system.conf.d/tinkerboard-watchdog.conf << _WATCHDOG_
[Manager]
RuntimeWatchdogSec=60
ShutdownWatchdogSec=600
_WATCHDOG_

# power management tweaks to keep the cpu idle and the system happy
cat > /etc/default/tlp << _TLP_
TLP_ENABLE=1
TLP_DEFAULT_MODE=AC
TLP_PERSISTENT_DEFAULT=0
DISK_IDLE_SECS_ON_AC=15
MAX_LOST_WORK_SECS_ON_AC=60
CPU_SCALING_GOVERNOR_ON_AC=conservative
CPU_SCALING_MIN_FREQ_ON_AC=126000
CPU_SCALING_MAX_FREQ_ON_AC=1608000
CPU_HWP_ON_AC=balance_power
CPU_MIN_PERF_ON_AC=0
CPU_MAX_PERF_ON_AC=100
CPU_BOOST_ON_AC=1
SCHED_POWERSAVE_ON_AC=1
NMI_WATCHDOG=0
ENERGY_PERF_POLICY_ON_AC=balance-power
DISK_DEVICES="mmcblk0"
DISK_APM_LEVEL_ON_AC="128"
DISK_SPINDOWN_TIMEOUT_ON_AC="1"
DISK_IOSCHED="kyber"
SATA_LINKPWR_ON_AC="med_power_with_dipm min_power"
AHCI_RUNTIME_PM_ON_AC=on
AHCI_RUNTIME_PM_TIMEOUT=15
PCIE_ASPM_ON_AC=powersave
SOUND_POWER_SAVE_ON_AC=1
SOUND_POWER_SAVE_CONTROLLER=Y
RUNTIME_PM_ON_AC=auto
USB_AUTOSUSPEND=1
USB_BLACKLIST_BTUSB=0
USB_BLACKLIST_PHONE=0
USB_BLACKLIST_PRINTER=0
USB_BLACKLIST_WWAN=0
RESTORE_DEVICE_STATE_ON_STARTUP=0
DEVICES_TO_DISABLE_ON_STARTUP="bluetooth wifi"
DEVICES_TO_DISABLE_ON_SHUTDOWN="bluetooth wifi wwan"
DEVICES_TO_ENABLE_ON_AC=""
_TLP_

echo ":: << Install armbian tinkerboard tweaks and kernel"
echo ":: << << << << << << << << << << << << << << << <<"
echo
