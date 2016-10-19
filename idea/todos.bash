#!/bin/bash

export MY_BASHRC_CONFIG="$HOME/.mybash_configs"

export FILESTORE_TODOLIST="$MY_BASHRC_CONFIG/.todo_list"
export FILESTORE_ACTIONITEMS="$MY_BASHRC_CONFIG/.actions"
export FILESTORE_DAILY="$MY_BASHRC_CONFIG/.daily"

if [ ! -d "$MY_BASHRC_CONFIG" ] ; then
    mkdir -p $MY_BASHRC_CONFIG
    echo > $FILESTORE_TODOLIST
    echo > $FILESTORE_ACTIONITEMS
    echo > $FILESTORE_DAILY
fi

alias editdaily="vim $FILESTORE_DAILY"
alias editactions="vim $FILESTORE_ACTIONITEMS"
alias edittodolist="vim $FILESTORE_TODOLIST"
alias editalltodo="editactions;editdaily;edittodolist"

function printdaily()
{
if [ -f $FILESTORE_DAILY ] ; then
    echo ================ Every Day ================
    echo 
    cat $FILESTORE_DAILY
    echo
    echo ===========================================
else
    touch $FILESTORE_DAILY
    echo "Init dailys in $FILESTORE_DAILY, you can call editdaily to edit them"
fi
}
function printtodolist()
{
if [ -f $FILESTORE_TODOLIST ] ; then
    echo ================ TODO LIST ================
    echo 
    cat $FILESTORE_TODOLIST
    echo
    echo ===========================================
else
    touch $FILESTORE_TODOLIST
    echo "Init todolist in $FILESTORE_TODOLIST, you can call edittodolist to edit them"
fi
}
function printactions()
{
if [ -f $FILESTORE_ACTIONITEMS ] ; then
    echo ================= ACTIONS =================
    echo 
    cat $FILESTORE_ACTIONITEMS
    echo
    echo ===========================================
else
    touch $FILESTORE_ACTIONITEMS
    echo "Init actions in $FILESTORE_ACTIONITEMS, you can call editactions to edit them"
fi
}

function printalltodos()
{
    echo

    local storeColor=$GREP_COLOR
    local has_print_something="false"

    if [ ! $storeColor ] ; then
        storeColor="01;31"
    fi

if [ "$(cat $FILESTORE_DAILY)" ] ; then
    export GREP_COLOR="05;36"
    echo ================ Every Day ================ | grep "Every Day"
    echo 
    export GREP_COLOR="05;32"
    cat -n $FILESTORE_DAILY | egrep *.
    echo
    has_print_something="true"
fi

if [ "$(cat $FILESTORE_TODOLIST)" ] ; then
    export GREP_COLOR="05;36"
    echo ================ TODO LIST ================ | grep "TODO LIST"
    echo 
    export GREP_COLOR="01;33"
    cat -n $FILESTORE_TODOLIST | egrep *.
    echo
    has_print_something="true"
fi

if [ "$(cat $FILESTORE_ACTIONITEMS)" ] ; then
    export GREP_COLOR="01;31"
    echo ================= ACTIONS ================= |  grep "ACTIONS"
    echo 
    export GREP_COLOR="07;31"
    cat -n $FILESTORE_ACTIONITEMS | egrep *.
    echo
    has_print_something="true"
fi

if [ "$has_print_something" = "true" ] ; then
    echo ===========================================


    echo
    export GREP_COLOR=$storeColor
fi
}

printalltodos
