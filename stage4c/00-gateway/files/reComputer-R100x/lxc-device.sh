#!/bin/bash

set -e

CONTAINER_NAME="SenseCAP"
LOG_TAG="[LXC-Device]"

# Only interfaces used by the container are mapped. Host bridges and other
# user-managed interfaces must stay on the host.
EXCLUDE_RE="^(eth1|lo|lxcbr0)"
INCLUDE_RE="^(wwan|wlan|enx|usb)"
[ -f /etc/default/lxc-device ] && . /etc/default/lxc-device

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') ${LOG_TAG} $1"
}

main() {
    log_message "Starting LXC Device Mapping Service"
    log_message "Container: $CONTAINER_NAME"

    while true; do
        # Without a cmdline regdom, brcmfmac registers wlan as soft-blocked
        # (classic Pi "no country" behavior) and nothing inside the container
        # can bring the interface up. Unblock by type before handing it over.
        for rf in /sys/class/rfkill/*; do
            if [ "$(cat "$rf/type" 2>/dev/null)" = "wlan" ] && [ "$(cat "$rf/soft" 2>/dev/null)" = "1" ]; then
                echo 0 > "$rf/soft" 2>/dev/null && log_message "Unblocked rfkill for wlan"
            fi
        done

        if sudo lxc-info -n "$CONTAINER_NAME" 2>/dev/null | grep -q "RUNNING"; then
            for iface in $(ip -o link show | awk -F': ' '{print $2}' | grep -v '@'); do
                [[ "$iface" =~ $EXCLUDE_RE ]] && continue
                [[ "$iface" =~ $INCLUDE_RE ]] || continue

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
