#!/bin/bash
busypercent=$(cat /sys/class/hwmon/hwmon3/device/gpu_busy_percent)
raw_temp=$(cat /sys/class/drm/card0/device/hwmon/hwmon3/temp1_input)

raw_clock=$(cat /sys/class/drm/card0/device/pp_dpm_sclk | grep -Eo '[0-9]{0,4}Mhz \W' | sed "s/Mhz \*//")
clock=$(echo "scale=1;$raw_clock/1000" | bc | sed -e 's/^-\./-0./' -e 's/^\./0./')

tempersature=$(($raw_temp/1000))
deviceinfo=$(glxinfo -B | grep 'Device:' | sed 's/^.*: //')
driverinfo=$(glxinfo -B | grep "OpenGL version")

echo '{"text": "'$clock'GHz |   '$tempersature'°C <span color=\"#000000\">| '$busypercent'%</span>", "class": "custom-gpu", "tooltip": "<b>'$deviceinfo'</b>\n'$driverinfo'"}'
