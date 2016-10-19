#!/bin/bash

_droid_proc_pid()
{
    local processlist cur processname pid procnodes

    cur="${COMP_WORDS[COMP_CWORD]}"

    case $COMP_CWORD in
    1)
        _droid_proc_pid_simple
        return 0
    ;;
    2)
        processname="${COMP_WORDS[1]}"

        # Name for pid?
        pid=$(filter_numbers $processname)
        if [ "$processname" != "$pid" ] ; then
            pid=$(droid_proc_pid $processname)
        fi

        # Use the aosp cmd to find nodes under /proc/$pid/.
        _adb_util_list_files "none" /proc/$pid/$cur

        # the result contains /proc/$pid, trim them.
        local index reply_max
        COMPREPLY=( ${COMPREPLY[*]} )
        reply_max="${#COMPREPLY[@]}"
        index=0
        while [ $(expr $index '<' ${reply_max}) = 1 ]
        do
            COMPREPLY[$index]=$(echo ${COMPREPLY[$index]} | sed -e "s?^/proc/$pid/??g")
            index=$(( $index + 1 ))
        done

    ;;
    esac
}

complete -F _droid_proc_pid droid_proc_pid

_droid_proc_stat()
{
    local processlist cur processname pid procnodes

    cur="${COMP_WORDS[COMP_CWORD]}"

    case $COMP_CWORD in
    1)
        _droid_proc_pid_simple
        return 0
    ;;
    2)
        COMPREPLY=( $(compgen -W "${BASHRC_PROC_TYPES[*]}" -- "$cur") )
    ;;
    esac
}

complete -F _droid_proc_stat droid_proc_stat

_droid_proc_pid_simple()
{
    local processlist cur
    cur="${COMP_WORDS[COMP_CWORD]}"

    processlist=`adb shell ps | awk '{print $9}'`
    COMPREPLY=( $(compgen -W "$processlist" -- "$cur") )
    return 0
}

complete -F _droid_proc_pid_simple droid_proc_kill
complete -F _droid_proc_pid_simple droid_proc_quit
complete -F _droid_proc_pid_simple droid_proc_signal
