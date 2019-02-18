vagrant-down:
	-vagrant destroy --force

vagrant-up:
	vagrant up

.PHONY: up
up: vagrant-up

.PHONY: down
down: vagrant-down

vagrant-rebuild: vagrant-down vagrant-up

tinkerboard-armbian-beta-bionic:
	vagrant ssh -- sudo make -C /srv/src/ -f /srv/src/Makefile.vagrant $@

rpi3-ubuntu-bionic-arm64:
	vagrant ssh -- sudo make -C /srv/src/ -f /srv/src/Makefile.vagrant $@

rpi3-ubuntu-cosmic-arm64:
	vagrant ssh -- sudo make -C /srv/src/ -f /srv/src/Makefile.vagrant $@
