#!/bin/bash

DETECT_PIN=578

echo $DETECT_PIN > /sys/class/gpio/export
echo in > /sys/class/gpio/gpio$DETECT_PIN/direction

value=$(cat /sys/class/gpio/gpio$DETECT_PIN/value)

if [ "$value" == "1" ]; then
    echo "Start to dtoverlay reComputer-R21"
    dtoverlay reComputer-R21
else
    echo "R21 expansion board not detected"
fi
