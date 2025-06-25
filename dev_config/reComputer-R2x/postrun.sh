#!/bin/bash -e
set -x

# install examples
echo ${FIRST_USER_NAME}

cd /home/${FIRST_USER_NAME}
pwd
uname -a
git clone https://github.com/hailo-ai/hailo-rpi5-examples.git --depth 1

free -h
swapon --show
df -h
