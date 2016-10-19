#!/bin/bash

function add_java_8_repository()
{
    local vivid_repo="deb http://cz.archive.ubuntu.com/ubuntu vivid main universe"
    local src_list="/etc/apt/sources.list"
    if [ -z "$(grep -r "$vivid_repo" $src_list)" ] ; then

        echo "Adding $vivid_repo into $src_list ..."
        echo
        sudo chmod 0666 $src_list
        sudo echo "$vivid_repo" >> $src_list
        sudo chmod 0644 $src_list
    else
        echo "Already add $vivid_repo"
        echo
    fi
}

function apt_update()
{
    echo "Updating apt ..."
    echo
    sudo apt-get update
}

function install_java_8()
{
    echo "Try to install openjdk-8-jdk"
    echo
    sudo apt-get install openjdk-8-jdk
}

add_java_8_repository
apt_update
install_java_8
