#!/bin/bash -e
if [ ! -d "\${ROOTFS_DIR}" ]; then
copy_previous
fi

chmod 755 ./00-gateway/files/usb-automount.sh || true
chmod 644 ./00-gateway/files/usb-automount.service || true
chmod 755 ./00-gateway/files/usb-automount.sh || true
chmod 644 ./00-gateway/files/usb-automount.service || true