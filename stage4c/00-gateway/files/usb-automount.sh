#!/bin/bash

MOUNT_BASE="/media"
mkdir -p "$MOUNT_BASE"

lsblk -rpno NAME,TYPE | while read dev type; do
    if [[ "$type" == "part" ]]; then
        mountpoint=$(lsblk -no MOUNTPOINT "$dev")
        if [ -z "$mountpoint" ]; then
            label=$(blkid -s LABEL -o value "$dev")
            name=$(basename "$dev")
            target="$MOUNT_BASE/usb-${label:-$name}"
            mkdir -p "$target"
            mount "$dev" "$target"
        fi
    fi
done
