#!/bin/bash -e
set -x

SEEED_DEV_NAME=${IMG_NAME}
if [ -d "files/$SEEED_DEV_NAME-config" ]; then
    log "Begin copy files for seeed $SEEED_DEV_NAME"
    cp -r ./files/$SEEED_DEV_NAME-config/* ${ROOTFS_DIR}/var/lib/lxc/openwrt/config
fi

# For security authentication, change http in apt source to https
on_chroot << EOF
set -x
# Download LXC image from GitHub
wget https://github.com/is-qian/recomputer-gateway/releases/latest/download/openwrt-armsr-armv8-generic-rootfs.tar.gz \
 -O /tmp/openwrt-rootfs.tar.gz

# Create LXC container
mkdir -p /var/lib/lxc/openwrt/rootfs
tar -xzf /tmp/openwrt-rootfs.tar.gz -C /var/lib/lxc/openwrt/rootfs

# Create config file if not exists
if [ ! -f /var/lib/lxc/openwrt/config ]; then
    echo "lxc.rootfs.path = dir:/var/lib/lxc/openwrt/rootfs" > /var/lib/lxc/openwrt/config
    echo "lxc.uts.name = openwrt" >> /var/lib/lxc/openwrt/config
fi

# Set LXC to auto-start
if ! grep -q "lxc.start.auto" /var/lib/lxc/openwrt/config; then
    echo "lxc.start.auto = 1" >> /var/lib/lxc/openwrt/config
fi

# Fix Read-only file system error for GPIO
if ! grep -q "lxc.mount.auto = sys:rw" /var/lib/lxc/openwrt/config; then
    echo "lxc.mount.auto = sys:rw" >> /var/lib/lxc/openwrt/config
fi

# Clean up
rm /tmp/openwrt-rootfs.tar.gz
EOF

