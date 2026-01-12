#!/bin/bash

# reComputer R100x initialization script
# Monitor and configure 4G module and WiFi interface for SenseCAP container
# Must run with sudo/root privileges

LOG_TAG="[reComputer-R100x-init]"
CONTAINER_NAME="SenseCAP"
CHECK_INTERVAL=10
AT_RETRY_INTERVAL=120

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root"
    exit 1
fi

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $LOG_TAG $1"
}

# Send AT command to 4G module
send_at_command() {
    local cmd="$1"
    local device="$2"
    log "Sending AT command: $cmd to $device"
    echo -e "${cmd}\r" > "$device"
    sleep 1
}

# Check if container is running
is_container_running() {
    local container="$1"
    local state=$(lxc-info -n "$container" -s 2>/dev/null | awk '/^State:/ {print $2}')
    [ "$state" = "RUNNING" ]
}

# Check if interface exists in container
interface_in_container() {
    local interface="$1"
    lxc-attach -n "$CONTAINER_NAME" -- ip link show "$interface" &>/dev/null
}

# Check if interface exists in host
interface_in_host() {
    local interface="$1"
    ip link show "$interface" &>/dev/null
}

# Map interface to container using lxc-device
map_interface_to_container() {
    local interface="$1"
    
    log "Mapping $interface to container using lxc-device"
    if lxc-device -n "$CONTAINER_NAME" add "$interface" "$interface" 2>/dev/null; then
        log "Successfully mapped $interface to container"
        # Bring up interface inside container
        lxc-attach -n "$CONTAINER_NAME" -- ip link set "$interface" up 2>/dev/null
        return 0
    else
        log "Failed to map $interface to container"
        return 1
    fi
}

# Monitor and configure WiFi interface
monitor_wifi() {
    while true; do
        # Check if wlan0 exists in container
        if interface_in_container "wlan0"; then
            # wlan0 already in container, do nothing
            :
        else
            # wlan0 not in container, check if it exists in host
            if interface_in_host "wlan0"; then
                log "wlan0 detected in host, mapping to container"
                map_interface_to_container "wlan0"
            else
                # wlan0 not in host, do nothing
                :
            fi
        fi
        
        sleep $CHECK_INTERVAL
    done
}

# Monitor and configure 4G module
monitor_4g_module() {
    local last_at_time=0
    
    while true; do
        # Check if wwan0 exists in container
        if interface_in_container "wwan0"; then
            # wwan0 already in container, do nothing
            :
        else
            # wwan0 not in container, check if it exists in host
            if interface_in_host "wwan0"; then
                log "wwan0 detected in host, mapping to container"
                map_interface_to_container "wwan0"
            else
                # wwan0 not in host, check if 4G module exists
                if [ -e /dev/ttyUSB2 ]; then
                    # Check if enough time has passed since last AT command
                    current_time=$(date +%s)
                    if [ $((current_time - last_at_time)) -ge $AT_RETRY_INTERVAL ]; then
                        log "wwan0 not found, 4G module detected, sending AT commands"
                        send_at_command 'AT+QCFG="usbnet",0' /dev/ttyUSB2
                        sleep 2
                        send_at_command 'AT+CFUN=1,1' /dev/ttyUSB2
                        last_at_time=$current_time
                    fi
                else
                    # /dev/ttyUSB2 not found, do nothing
                    :
                fi
            fi
        fi
        
        sleep $CHECK_INTERVAL
    done
}

# Main
log "Starting reComputer R100x initialization daemon"
log "Container: $CONTAINER_NAME"

# Wait for container to start
while true; do
    if is_container_running "$CONTAINER_NAME"; then
        log "Container $CONTAINER_NAME is running"
        break
    else
        log "Waiting for container $CONTAINER_NAME to start..."
        sleep $CHECK_INTERVAL
    fi
done

# Container is running, start monitors
log "Starting interface monitors..."

# Run monitors in background
monitor_wifi &
monitor_4g_module &

# Wait for all background processes
wait
