#!/bin/bash

GPIO_PIN=639

if [ ! -d "/sys/class/gpio/gpio${GPIO_PIN}" ]; then
    echo "$GPIO_PIN" > /sys/class/gpio/export
fi

echo out > /sys/class/gpio/gpio${GPIO_PIN}/direction
echo 0 > /sys/class/gpio/gpio${GPIO_PIN}/value
