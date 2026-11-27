#!/bin/bash

set -e

CONTAINER_NAME="SenseCAP"
LOG_TAG="[LXC-Device]"

# Only interfaces used by the container are mapped. Host bridges and other
# user-managed interfaces must stay on the host.
EXCLUDE_RE="^(eth1|lo|lxcbr0)"
INCLUDE_RE="^(wwan|wlan|enx|usb)"
WWAN_RE="^wwan"
[ -f /etc/default/lxc-device ] && . /etc/default/lxc-device

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') ${LOG_TAG} $1"
}

# The container's netifd redials the moment the modem re-enumerates, before
# wwan0 lands here, and then parks the LTE interface as unavailable for good.
# Re-announcing the QMI device once wwan0 is in makes it redial.
reannounce_qmi_device() {
    log_message "Re-announcing QMI device to container"
    sudo lxc-attach -n "$CONTAINER_NAME" -- /bin/sh -c \
        'for u in /sys/class/usbmisc/cdc-wdm*/uevent; do [ -e "$u" ] && echo add > "$u"; done' \
        || log_message "Failed to re-announce QMI device"
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
                    [[ "$iface" =~ $WWAN_RE ]] && reannounce_qmi_device
                fi
            done
        fi

        sleep 10
    done
}

main
