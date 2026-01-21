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
            for iface in $(ip -o link show | awk -F': ' '{print $2}' | grep -v '@'); do
                # Skip eth1, lo, lxcbr0 interfaces
                [[ "$iface" =~ ^(eth1|lo|lxcbr0) ]] && continue
                
                # Map if not already mapped
                if ip link show "$iface" &>/dev/null; then
                    log_message "Mapping $iface to container"
                    sudo lxc-device -n "$CONTAINER_NAME" add "$iface" 
                fi
            done
        fi
        
        sleep 10
    done
}

main
