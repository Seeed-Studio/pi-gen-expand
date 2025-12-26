#!/bin/bash -e
set -x

# Detect if running in chroot environment
IN_CHROOT=0
if [ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]; then
    IN_CHROOT=1
fi

if [ $IN_CHROOT -eq 1 ]; then
    echo "=== Running in chroot: installing hailo-all with preemptive postinst patch ==="
    
    # Update package lists
    apt-get update
    
    # Download hailort-pcie-driver package without installing
    cd /tmp
    apt-get download hailort-pcie-driver
    
    # Get the actual filename
    DEB_FILE=$(ls hailort-pcie-driver_*.deb 2>/dev/null | head -1)

    # Extract version from deb filename for later use
    if [ -n "$DEB_FILE" ]; then
        HAILO_VERSION=$(echo "$DEB_FILE" | sed "s/hailort-pcie-driver_\([0-9.]*\)_.*/\1/")
        echo "=== Detected hailo version from deb package: $HAILO_VERSION ==="
    fi
    
    if [ -n "$DEB_FILE" ]; then
        echo "=== Found $DEB_FILE, patching postinst ==="
        
        # Extract control files including postinst
        mkdir -p /tmp/pcie-DEBIAN
        dpkg-deb -e "$DEB_FILE" /tmp/pcie-DEBIAN
        
        if [ -f /tmp/pcie-DEBIAN/postinst ]; then
            # Backup original postinst
            cp /tmp/pcie-DEBIAN/postinst /tmp/pcie-DEBIAN/postinst.bak
            
            # Create new postinst with chroot detection at the beginning
            cat > /tmp/pcie-DEBIAN/postinst << 'POSTINST_EOF'
#!/bin/bash
set -eEuo pipefail

readonly PKG_NAME="hailort-pcie-driver"
readonly LOG="/var/log/${PKG_NAME}.deb.log"
echo "######### $(date) #########" >> $LOG

# Check if we're in chroot - exit early to avoid modprobe failure
if [ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]; then
    echo "Running in chroot environment" | tee -a $LOG
    echo "Skipping driver compilation and loading" | tee -a $LOG
    echo "Driver will be loaded on first boot" | tee -a $LOG
    exit 0
fi

# Original postinst logic (only runs on real hardware)
POSTINST_EOF
            
            # Append original postinst content (skip shebang and set -e lines)
            tail -n +4 /tmp/pcie-DEBIAN/postinst.bak >> /tmp/pcie-DEBIAN/postinst
            chmod +x /tmp/pcie-DEBIAN/postinst
            
            # Extract data files
            mkdir -p /tmp/pcie-data
            dpkg-deb -x "$DEB_FILE" /tmp/pcie-data
            
            # Copy modified control files
            mkdir -p /tmp/pcie-data/DEBIAN
            cp -r /tmp/pcie-DEBIAN/* /tmp/pcie-data/DEBIAN/
            
            # Repack the deb with modified postinst
            dpkg-deb --root-owner-group -b /tmp/pcie-data /tmp/hailort-pcie-driver-patched.deb
            
            # Install the patched package
            dpkg -i /tmp/hailort-pcie-driver-patched.deb
            
            echo "=== Patched hailort-pcie-driver installed ==="
        fi
        
        # Cleanup temporary files
        rm -rf /tmp/pcie-DEBIAN /tmp/pcie-data "$DEB_FILE"
    fi
    
    # Now install hailo-all (should succeed)
    DEBIAN_FRONTEND=noninteractive apt-get install -y hailo-all
    
    # Final cleanup
    rm -f /tmp/hailort-pcie-driver-patched.deb
    
    echo "=== hailo-all installation completed in chroot ==="
else
    echo "=== Running on real hardware: installing hailo-all ==="
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install -y hailo-all
fi

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

VERSION="${HAILO_VERSION:-$(apt list hailo-all 2>/dev/null | grep hailo-all | awk '{print $2}' | cut -d' ' -f1)}"
echo "Hailo version: $VERSION"
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