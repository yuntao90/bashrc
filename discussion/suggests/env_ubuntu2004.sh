#!/bin/bash

SUDO="sudo"

if [ $UID -eq 0 ] ; then
SUDO=""
fi

$SUDO apt update
# $SUDO apt upgrade

# CVS
$SUDO apt install -y git git-cvs subversion gitg gitk
# Build toolchains 
$SUDO apt install -y cmake --install-suggests
$SUDO apt install -y automake gcc-aarch64-linux-gnu flake8 libtool \
        u-boot-tools gcc-arm-linux-gnueabihf gcc-i686-linux-gnu bison ccache

# Tools
$SUDO apt install -y curl p7zip-full unrar smbnetfs smbclient \
        cifs-utils jq v4l-utils cpufrequtils vlc ffmpeg

# Dev libraries

$SUDO snap install code --classic
$SUDO snap install htop


