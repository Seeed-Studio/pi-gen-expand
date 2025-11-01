#!/bin/bash -e
set -x

if [ -d "files/pam.d" ]; then
	log "Begin ${SUB_STAGE_DIR}/files/pam.d"
	install -d ${ROOTFS_DIR}/etc/pam.d
	cp -v files/pam.d/* ${ROOTFS_DIR}/etc/pam.d/
	log "End ${SUB_STAGE_DIR}/files/pam.d"
fi

# For security authentication, change http in apt source to https
on_chroot << EOF
set -x
grep -R --line-number -E 'http://' /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null || echo "have no http source"
sed -i 's|http://|https://|g' /etc/apt/sources.list
for file in /etc/apt/sources.list.d/*.sources ; do
	[ -f "\$file" ] || continue
	sed -i 's|http://|https://|g' "\$file"
done
curl -fsSL https://archive.raspberrypi.com/debian/raspberrypi.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/rpi-archive-keyring.gpg
for file in /etc/apt/sources.list.d/*.list ; do
	[ -f "\$file" ] || continue
	sed -i 's|http://|[signed-by=/usr/share/keyrings/rpi-archive-keyring.gpg] https://|g' "\$file"
done
EOF
