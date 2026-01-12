#!/bin/bash

set -e

CONTAINER_NAME="SenseCAP"
LOG_TAG="[LXC-Device]"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') ${LOG_TAG} $1"
}

main() {
    log_message "Starting LXC Device Mapping Service"
    log_message "Container: $CONTAINER_NAME"
    
    while true; do
        # Check if container is running
        if sudo lxc-info -n "$CONTAINER_NAME" 2>/dev/null | grep -q "RUNNING"; then
            # Check and map ttyUSB2
            if [ -e "/dev/ttyUSB2" ]; then
                if ! sudo lxc-attach -n "$CONTAINER_NAME" -- test -e "/dev/ttyUSB2" 2>/dev/null; then
                    log_message "Mapping /dev/ttyUSB2 to container"
                    sudo lxc-device -n "$CONTAINER_NAME" add "/dev/ttyUSB2" 
                fi
            fi
            
            # Check and map wwan0
            if ip link show wwan0 &>/dev/null; then
                log_message "Mapping wwan0 to container"
                sudo lxc-device -n "$CONTAINER_NAME" add "wwan0"
            fi

            # Check and map wlan0
            if ip link show wlan0 &>/dev/null; then
                log_message "Mapping wlan0 to container"
                sudo lxc-device -n "$CONTAINER_NAME" add "wlan0"
            fi
        fi
        
        sleep 10
    done
}

main
