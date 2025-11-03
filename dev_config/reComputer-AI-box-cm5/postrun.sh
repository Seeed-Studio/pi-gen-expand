#!/bin/bash -e
set -x

arch_r=$(dpkg --print-architecture)
BOOKWORM_NUM=12
DEBIAN_VER=`cat /etc/debian_version`
DEBIAN_NUM=$(echo "$DEBIAN_VER" | awk -F'.' '{print $1}')

_VER_RUN=""
function get_kernel_version() {
  local ZIMAGE IMG_OFFSET

  if [ -z "$_VER_RUN" ]; then
    if [ $DEBIAN_NUM -lt $BOOKWORM_NUM ]; then
      ZIMAGE=/boot/kernel7l.img
      if [ $arch_r == "arm64" ]; then
        ZIMAGE=/boot/kernel8.img
      fi
    else
      ZIMAGE=/boot/firmware/kernel7l.img
      if [[ $arch_r == "arm64" || $uname_r == *rpi-v8* ]]; then
        ZIMAGE=/boot/firmware/kernel8.img
        # if is pi5 or cm5, we use kernel_2712.img, if rpi-2712 in uname_r
        if [[ $uname_r == *2712* ]]; then
          ZIMAGE=/boot/firmware/kernel_2712.img
        fi
      fi
    fi
  fi

  [ -f /boot/firmware/vmlinuz ] && ZIMAGE=/boot/firmware/vmlinuz
  IMG_OFFSET=$(LC_ALL=C grep -abo $'\x1f\x8b\x08\x00' $ZIMAGE | head -n 1 | cut -d ':' -f 1)
  _VER_RUN=$(dd if=$ZIMAGE obs=64K ibs=4 skip=$(( IMG_OFFSET / 4)) 2>/dev/null | zcat | grep -a -m1 "Linux version" | strings | awk '{ print $3; }' | grep "[0-9]")

  echo "$_VER_RUN"
  
  return 0
}

kernelver=$(get_kernel_version)

VERSION=$(apt list hailo-all | grep hailo-all | awk '{print $2}' | cut -d' ' -f1)
git clone https://github.com/hailo-ai/hailort-drivers.git -b v$VERSION hailort-drivers
cd hailort-drivers/linux/pcie

make all kernelver=$kernelver

cd ../..

if [ -f "./download_firmware.sh" ]; then
    chmod +x ./download_firmware.sh
    ./download_firmware.sh
    mkdir -p /lib/firmware/hailo
    mv hailo8_fw.4.*.bin /lib/firmware/hailo/hailo8_fw.bin
else
    echo "Warning: download_firmware.sh not found, skipping firmware installation"
fi

mkdir -p /etc/udev/rules.d
cp ./linux/pcie/51-hailo-udev.rules /etc/udev/rules.d/

rm -rf hailort-drivers

# install examples
echo ${FIRST_USER_NAME}
sudo echo ${FIRST_USER_NAME}

cd /home/${FIRST_USER_NAME}
pwd
uname -a
git clone https://github.com/hailo-ai/hailo-rpi5-examples.git
cd hailo-rpi5-examples
sed -i 's/device_arch=.*$/device_arch=HAILO8/g' setup_env.sh
sed -i '/sudo apt install python3-gi python3-gi-cairo/ s/$/ -y/' install.sh
./install.sh || true

free -h
swapon --show
df -h

# clean temp files and caches
apt-get -y autoremove --purge
apt-get -y clean
rm -rf /tmp/*