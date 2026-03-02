#!/bin/bash -e
set -x

SEEED_DEV_NAME=${IMG_NAME}
if [ -f "files/$SEEED_DEV_NAME/lxc-config" ]; then
    log "Begin copy files for seeed $SEEED_DEV_NAME"
    mkdir -p ${ROOTFS_DIR}/var/lib/lxc/SenseCAP
    cp ./files/$SEEED_DEV_NAME/lxc-config ${ROOTFS_DIR}/var/lib/lxc/SenseCAP/config
fi

# Install usb-automount service for auto-mounting USB drives
chmod +x ./files/usb-automount.sh
cp ./files/usb-automount.sh ${ROOTFS_DIR}/usr/local/bin/
cp ./files/usb-automount.service ${ROOTFS_DIR}/etc/systemd/system/
on_chroot << EOF
systemctl daemon-reload
systemctl enable usb-automount.service
EOF

# For security authentication, change http in apt source to https
on_chroot << EOF
set -x
# Download LXC image from GitHub
wget https://github.com/Seeed-Studio/sensecap-openwrt-feed/releases/latest/download/openwrt-armsr-armv8-generic-rootfs.tar.gz \
 -O /tmp/openwrt-rootfs.tar.gz

# Create LXC container
mkdir -p /var/lib/lxc/SenseCAP/rootfs
tar --warning=no-file-ignored -xzf /tmp/openwrt-rootfs.tar.gz -C /var/lib/lxc/SenseCAP/rootfs || true

# Create config file if not exists
if [ ! -f /var/lib/lxc/SenseCAP/config ]; then
    echo "lxc.rootfs.path = dir:/var/lib/lxc/SenseCAP/rootfs" > /var/lib/lxc/SenseCAP/config
    echo "lxc.uts.name = SenseCAP" >> /var/lib/lxc/SenseCAP/config
fi

# Set LXC to auto-start
if ! grep -q "lxc.start.auto" /var/lib/lxc/SenseCAP/config; then
    echo "lxc.start.auto = 1" >> /var/lib/lxc/SenseCAP/config
fi

# Clean up
rm /tmp/openwrt-rootfs.tar.gz
EOF

if [ -f "files/$SEEED_DEV_NAME/lxc-device.sh" ] && [ -f "files/$SEEED_DEV_NAME/lxc-device.service" ]; then
    log "Begin copy files for seeed $SEEED_DEV_NAME"
    chmod +x ./files/$SEEED_DEV_NAME/lxc-device.sh
    cp ./files/$SEEED_DEV_NAME/lxc-device.sh ${ROOTFS_DIR}/usr/local/bin/
    cp ./files/$SEEED_DEV_NAME/lxc-device.service ${ROOTFS_DIR}/lib/systemd/system/
    on_chroot << EOF
systemctl daemon-reload
systemctl enable lxc-device.service
EOF
fi

