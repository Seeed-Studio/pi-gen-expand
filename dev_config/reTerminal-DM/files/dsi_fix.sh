#!/bin/bash

for((;;))
do
sleep 0.5
if [ -f /sys/devices/platform/soc/fe700000.dsi/fe700000.dsi.0/dsi_state ]; then
	if [ ! `cat /sys/devices/platform/soc/fe700000.dsi/fe700000.dsi.0/dsi_state | grep ok` ]; then
		echo "dsi error detected~"
		DISPLAY=:0 xset s activate
		DISPLAY=:0 xset s activate
	fi
fi
done
