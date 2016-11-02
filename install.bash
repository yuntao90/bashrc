#!/bin/bash

# Check configuration exists
if [ -n "$MY_BASHRC_PLUS" ] ; then
    # Already install, check installation validation
    if [ "$MY_BASHRC_PLUS" != "`pwd`/bashrc.bash" ] ; then
        # Replace the new entry file
        sed -e "s?$MY_BASHRC_PLUS?`pwd`/bashrc.bash?g" $HOME/.bashrc > new_bashrc
        mv new_bashrc $HOME/.bashrc
    else
        echo "Check ok, already exists"
    fi
else
    echo "MY_BASHRC_PLUS is not set"
    MY_BASHRC_PLUS="$(cat $HOME/.bashrc | grep "export MY_BASHRC_PLUS=" | sed -e "s?export MY_BASHRC_PLUS=??g")"
    echo "found $MY_BASHRC_PLUS"
    if [ -n "$MY_BASHRC_PLUS" ] ; then
        # installed but does not take effects? Update that value.
        sed -e "s?$MY_BASHRC_PLUS?`pwd`/bashrc.bash?g" $HOME/.bashrc > new_bashrc
        mv new_bashrc $HOME/.bashrc
    else
        # new installation
        echo "New installtion"
        echo >> $HOME/.bashrc
        echo "export MY_BASHRC_PLUS=`pwd`/bashrc.bash" >> $HOME/.bashrc
        echo \
'
if [ -f "$MY_BASHRC_PLUS" ] ; then
    source $MY_BASHRC_PLUS
fi
' >> $HOME/.bashrc
    fi
fi

echo "Checking tool named parallel"
parallel_path=`which parallel`
if [ -z "$parallel_path" ] ; then
mkdir -p ~/tools/bin/
cp install/bin/parallel ~/tools/bin/.
fi

echo "Install complete, reloading $HOME/.bashrc"
source $HOME/.bashrc
