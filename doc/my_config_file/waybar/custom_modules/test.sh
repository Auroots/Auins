#!/bin/bash
    frequency_sum=0
    sum=0
cpuinfo(){
    core=$(grep -c "processor" /proc/cpuinfo)

    for ((i=-1; i<"$core";)) do
        i=$((i+1))
        if [ $i -lt $core ]; then
            frequency=$(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_cur_freq)
            frequency_sum=$((frequency_sum+$frequency / 8 / 10000 ))
            
        else
            exit 0;
        fi
        echo $frequency_sum
    done

    
}
# cpu1=$(cat /sys/devices/system/cpu/cpu1/cpufreq/scaling_cur_freq)
cpuinfo