#!/bin/bash

function has_command()
{
    local validate_command="$1"
    local validate_result=`type -t $validate_command`

    if [ -n "$validate_result" ] ; then
        return 0
    fi
    return 1
}

SUDO="sudo"

if [ $UID -eq 0 ] ; then
SUDO=""
fi

INSTALL_PKGS="linux-tools-generic cpufrequtils acpi lm-sensors"

if ! has_command jq ; then
INSTALL_PKGS="$INSTALL_PKGS jq"
fi

$SUDO apt install  $INSTALL_PKGS

MY_DIR=$(dirname $(realpath ${BASH_SOURCE[0]}))

$SUDO cp -v $MY_DIR/fan_speed.conf /etc/.
$SUDO cp -v $MY_DIR/self-speedup-cpu.service $MY_DIR/self-speedup-fan.service /lib/systemd/system/.

$SUDO mkdir -p /usr/local/bin
$SUDO cp $MY_DIR/self-speedup-cpu.sh $MY_DIR/self-speedup-fan.sh /usr/local/bin/.

$SUDO systemctl enable self-speedup-fan self-speedup-cpu
$SUDO systemctl restart self-speedup-fan self-speedup-cpu
