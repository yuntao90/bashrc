#!/bin/bash

# Only take effects on Thinkpad-T14-GEN1 (i5-10210U)
# And ensure that following command has been executed:
#  $ echo 'options thinkpad_acpi fan_control=1' | sudo tee -a /etc/modprobe.d/thinkpad_acpi.conf

POLICY_FILE=/etc/fan_speed.conf

SUDO="sudo"

if [ $UID -eq 0 ] ; then
SUDO=""
fi

$SUDO mkdir -p /var/run/self-speedup-fan

while [ true ] ; do
    if [[ -e $POLICY_FILE ]] ; then
        . "$POLICY_FILE"
    fi

    if [[ -z "$FAN_SPEED_LIST" ]] ; then
        FAN_SPEED_LIST=( 'level full-speed' 'level auto' )
    fi

    if [[ -z "$FAN_SLEEP_LIST" ]] ; then
        FAN_SLEEP_LIST=( 30 30 )
    fi

    idx=0

    while [[ $idx -lt ${#FAN_SPEED_LIST[@]} ]] ; do
        echo -n "[`date +'%Y-%2m-%2d %2H:%2M:%2S'`] Set fan speed to "
        echo "${FAN_SPEED_LIST[$idx]}" | $SUDO tee /proc/acpi/ibm/fan
        sleep "${FAN_SLEEP_LIST[$idx]}" 2>/dev/null
        idx=$(( $idx + 1 ))
    done
done
