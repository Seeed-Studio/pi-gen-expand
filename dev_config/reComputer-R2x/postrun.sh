#!/bin/bash -e
set -x

# install examples
echo ${FIRST_USER_NAME}

cd /home/${FIRST_USER_NAME}
pwd
uname -a
git clone https://github.com/hailo-ai/hailo-rpi5-examples.git --depth 1
cd hailo-rpi5-examples
sed -i 's/device_arch=.*$/device_arch=HAILO8/g' setup_env.sh
./install.sh || true

free -h
swapon --show
df -h
