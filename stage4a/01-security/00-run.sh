#!/bin/bash -e
set -x

if [ -d "files/pam.d" ]; then
	log "Begin ${SUB_STAGE_DIR}/files/pam.d"
	install -d ${ROOTFS_DIR}/etc/pam.d
	cp -v files/pam.d/* ${ROOTFS_DIR}/etc/pam.d/
	log "End ${SUB_STAGE_DIR}/files/pam.d"
fi

# For security authentication, change http in apt source to https(Only sources in deb822 format are supported)
on_chroot << EOF
set -x
grep -R --line-number -E 'http://' /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null || echo "have no http source"
sed -i 's|http://|https://|g' /etc/apt/sources.list
for file in /etc/apt/sources.list.d/*.sources ; do
	[ -f "\$file" ] || continue
	sed -i 's|http://|https://|g' "\$file"
done
EOF
