#!/bin/bash

echo
echo ":: >> >> >> >> >> >>"
echo ":: >> Enable armbian"

echo ":: Import armbian key"

apt-key add - <<'_ARMBIAN_KEY_'
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

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
cckukNqqFv/CXh+BZFlQT4DDvJlY0/KQFFKogQ==
=I/P8
-----END PGP PUBLIC KEY BLOCK-----
_ARMBIAN_KEY_

echo ":: Add armbian sources"
cat > /etc/apt/sources.list.d/armbian.list << _ARMBIAN_LIST_
deb http://apt.armbian.com/ $(lsb_release -s --codename) main
deb http://apt.armbian.com/ $(lsb_release -s --codename) utils
deb http://apt.armbian.com/ $(lsb_release -s --codename) $(lsb_release -s --codename)-utils
deb http://apt.armbian.com/ $(lsb_release -s --codename) $(lsb_release -s --codename)-desktop
_ARMBIAN_LIST_

echo ":: Update packages"
apt-get update
apt-get -y dist-upgrade

apt-get install -y armbian-config

echo ":: << Enable armbian"
echo ":: << << << << << <<"
echo
