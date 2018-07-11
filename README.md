home-network build system
-------------------------

A boring build infrastructure for openwrt and sbc nodes.

For openwrt the node definition is usually a set of `/etc/uci-defaults` scripts
and a `/etc/secrets/env` file (stored under secrets).

For sbc nodes a cloud-init based provisioning is used. The NoCloud/None
provider is configured with a mime multi-part cloud-init archive.
Single cloud-init yaml files may be passed through a golang envsubst like
templating to replace secrets on build time.
