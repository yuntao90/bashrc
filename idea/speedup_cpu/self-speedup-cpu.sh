#!/bin/bash

value=0
SUDO="sudo"

if [ $UID -eq 0 ] ; then
SUDO=""
fi

MAX_PERFORMANCE_MILLIWATT=18000000
POWERSAVE_MILLIWATT=8000000

mkdir -p /var/run/self-speedup-cpu

while [[ true ]] ; do
    if [[ $(acpi -a | egrep -o 'on-line') = 'on-line' ]] ; then
        if [ $value -ne $MAX_PERFORMANCE_MILLIWATT ] ; then
            $SUDO cpupower frequency-set -d '800MHz' -u '4.20GHz' &>/dev/null
            $SUDO cpufreq-set -d '800M' -u '4.2G' &>/dev/null
            echo "[`date +'%Y-%2m-%2d %2H:%2M:%2S'`] AC connected, set min watt as $(expr $MAX_PERFORMANCE_MILLIWATT / 1000000)W"
            value=$MAX_PERFORMANCE_MILLIWATT
        fi
    else
        if [[ $value -ne $POWERSAVE_MILLIWATT ]] ; then
            $SUDO cpupower frequency-set -d '400MHz' -u '1.60GHz' &>/dev/null
            $SUDO cpufreq-set -d '400M' -u '1.6G' &>/dev/null
            echo "[`date +'%Y-%2m-%2d %2H:%2M:%2S'`] AC may not connected, set min watt as $(expr $POWERSAVE_MILLIWATT / 1000000)W"
            value=$POWERSAVE_MILLIWATT
        fi
    fi
    echo $value | $SUDO tee '/sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_0_power_limit_uw' > /dev/null
    sleep 10
done

