#!/bin/bash

SUDO="sudo"

if [ $UID -eq 0 ] ; then
SUDO=""
fi

MY_DIR=.

$SUDO cp -v $MY_DIR/fan_speed.conf /etc/.
$SUDO cp -v $MY_DIR/self-speedup-cpu.service $MY_DIR/self-speedup-fan.service /lib/systemd/system/.

$SUDO mkdir -p /usr/local/bin
$SUDO cp $MY_DIR/self-speedup-cpu.sh $MY_DIR/self-speedup-fan.sh /usr/local/bin/.

$SUDO systemctl enable self-speedup-fan self-speedup-cpu
$SUDO systemctl restart self-speedup-fan self-speedup-cpu
