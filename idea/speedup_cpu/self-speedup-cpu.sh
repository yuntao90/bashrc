#!/bin/bash

# Only take effects on Thinkpad-T14-GEN1 (i5-10210U)
# And ensure that following command has been executed:
#  $ echo 'options thinkpad_acpi fan_control=1' | sudo tee -a /etc/modprobe.d/thinkpad_acpi.conf

value=0
SUDO="sudo"

if [ $UID -eq 0 ] ; then
SUDO=""
fi

mkdir -p /var/run/self-speedup-cpu

while [[ true ]] ; do
    if [[ $(acpi -a | egrep -o 'on-line') = 'on-line' ]] ; then
        if [ $value -ne 25000000 ] ; then
            # $SUDO cpupower frequency-set -g performance &>/dev/null
            $SUDO cpupower frequency-set -d '800MHz' -u '4.20GHz' &>/dev/null
            echo "[`date +'%Y-%2m-%2d %2H:%2M:%2S'`] AC connected, set min watt as 25W"
        fi
        value=25000000
    else
        if [[ $value -ne 8000000 ]] ; then
            # $SUDO cpupower frequency-set -g powersave &> /dev/null
            $SUDO cpupower frequency-set -d '400MHz' -u '1.60GHz' &>/dev/null
            echo "[`date +'%Y-%2m-%2d %2H:%2M:%2S'`] AC may not connected, set min watt as 8W"
        fi
        value=8000000
    fi
    echo $value | $SUDO tee '/sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_0_power_limit_uw' > /dev/null
    sleep 5
done

