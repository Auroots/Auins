#!/bin/bash
scaling=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
if [ $scaling = "performance" ]; then
	echo '{"text": "perf", "alt": "perf", "class": "performance", "tooltip": "<b>Governor</b> Performance"}'
	#echo ''
elif [ $scaling = "schedutil" ]; then
	echo '{"text": "sched", "class": "schedutil", "tooltip": "<b>Governor</b> Schedutil"}'
fi