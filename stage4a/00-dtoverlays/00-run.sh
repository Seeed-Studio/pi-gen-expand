#!/bin/bash -e
set -x

if [[ ${IMG_NAME} == "raspberrypi" ]]; then
	exit 0
fi

SEEED_DEV_NAME=${IMG_NAME}
GIT_MODULE='https://github.com/Seeed-Studio/seeed-linux-dtoverlays.git -b master --depth=1'

if [ "X$GIT_MODULE" != "X" ]; then
	MODULE_PATH=/seeed-linux-dtoverlays
	${PROXYCHAINS} git clone ${GIT_MODULE} "${ROOTFS_DIR}${MODULE_PATH}"
	# ${PROXYCHAINS} wget http://192.168.1.77/reTerminalDM/dt-blob-disp1-cam2.bin -O "${ROOTFS_DIR}/boot/dt-blob.bin"

	on_chroot << EOF
cd ${MODULE_PATH}
dpkg -l | grep kernel
./scripts/reTerminal.sh --device ${SEEED_DEV_NAME}
EOF

	rm -rfv "${ROOTFS_DIR}${MODULE_PATH}"
fi

# cat ${WORK_DIR}/config

if [ -f "purges" ]; then
	log "Begin ${SUB_STAGE_DIR}/purges"
	PACKAGES="$(sed -f "${SCRIPT_DIR}/remove-comments.sed" < "purges")"
	if [ -n "$PACKAGES" ]; then
		set +e
		for i in $PACKAGES; do
			on_chroot << EOF
apt-get autoremove --purge -y $i
EOF
		done
		set -e
		if [ "${USE_QCOW2}" = "1" ]; then
			on_chroot << EOF
apt-get clean
EOF
		fi
	fi
	log "End ${SUB_STAGE_DIR}/purges"
fi

if [ -f "python-packages" ]; then
	log "Begin ${SUB_STAGE_DIR}/python-packages"
	PACKAGES="$(sed -f "${SCRIPT_DIR}/remove-comments.sed" < "python-packages")"
	if [ -n "$PACKAGES" ]; then
		on_chroot << EOF
set -x
pip3 install $PACKAGES
EOF
	fi
	log "End ${SUB_STAGE_DIR}/python-packages"
fi

if [ -f "remove" ]; then
	log "Begin ${SUB_STAGE_DIR}/remove"
	PACKAGES="$(sed -f "${SCRIPT_DIR}/remove-comments.sed" < "remove")"
	on_chroot << EOF
rm -rfv $PACKAGES
EOF
	log "End ${SUB_STAGE_DIR}/remove"
fi


if [ -d "files" ]; then
    if [ "$SEEED_DEV_NAME" == "reComputer-R2x" ]; then
        log "Begin copy files special for seeed $SEEED_DEV_NAME"
        chmod +x ./files/r21_board_detect.sh
        cp ./files/r21_board_detect.sh ${ROOTFS_DIR}/usr/local/bin/
        cp ./files/r21_board_detect.service ${ROOTFS_DIR}/lib/systemd/system/
        on_chroot << EOF
systemctl daemon-reload
systemctl enable r21_board_detect.service
EOF
        log "End copy files special for seeed $SEEED_DEV_NAME"
    else
        log "Begin copy files special for seeed"
        mkdir -p ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config
        if [ -f "./files/wayfire.ini" ]; then
            cp ./files/wayfire.ini ${ROOTFS_DIR}/home/${FIRST_USER_NAME}/.config
        fi
        chmod +x ./files/dsi_fix.sh
        cp ./files/dsi_fix.sh ${ROOTFS_DIR}/var/
        cp ./files/seeed_dsifix.service ${ROOTFS_DIR}/lib/systemd/system/
        on_chroot << EOF
chown -vR ${FIRST_USER_NAME}:${FIRST_USER_NAME} /home/${FIRST_USER_NAME}/.config 
systemctl daemon-reload
systemctl enable seeed_dsifix.service
EOF
        log "End copy files special for seeed"
    fi
fi

if [ "${FIRST_USER_NAME}" != "root" ]; then
	on_chroot << EOF
chown -vR ${FIRST_USER_NAME}:${FIRST_USER_NAME} /home/${FIRST_USER_NAME}/.config
EOF
fi

if [ -f "postrun.sh" ]; then
    log "Begin ${SUB_STAGE_DIR}/postrun.sh"
    cp ./postrun.sh ${ROOTFS_DIR}/tmp/postrun.sh
    on_chroot << EOF
cd /tmp
chmod +x postrun.sh
./postrun.sh
rm -fv postrun.sh
EOF
fi
