#!/bin/bash

# Add the _cd completion into ccd, they are the same.
if has_command _cd ; then

if shopt -q cdable_vars; then
    complete -v -F _cd -o nospace ccd
else
    complete -F _cd -o nospace ccd
fi

fi # has_command _cd

_bd_comp_last_max_index=256

# Back directory completion
_bd()
{
    # Follow the _cd, no idea about why call this now
    if has_command _init_completion ; then
        _init_completion || return
    fi

    # Here is some different solutions,
    # Solution 1. Use the n_dir to display completion
    #   It is a stable one, but the displays are not
    #   verify obvious.
    # Solution 2. Use the echo to display the prompt
    #   That is very obvious but not work well with
    #   completion, so I limit the max index is 9.
    #
    # Currently solution is 2.
    #
    # You can set the BASHRC_BD_COMP_SOLUTION
    # into the local_env.bash

    local complete_solution="2"
    local limit="9"
    local limitCount

    if [ -n $BASHRC_BD_COMP_SOLUTION ] ; then
        case $BASHRC_BD_COMP_SOLUTION in
            "1")
                complete_solution="1"
                ;;
            "2")
                complete_solution="2"
                ;;
            *)
        esac
    fi

    if [ -n "$BASHRC_BD_COMP_LIMIT" ] ; then
        limit=$BASHRC_BD_COMP_LIMIT
    fi

    limitCount=$(expr ${limit} - 1 )
    local cur index debug

    # Find the recent input parameter
    cur="${COMP_WORDS[$COMP_CWORD]}"
    cur=$(filter_numbers $cur)

    # Dump var for debug, can use debug="true" to enable this
    if [ "$debug" = "true" ] ; then
    echo -e "\nCOMP_WORDS=${COMP_WORDS[$COMP_CWOWRD]}"
    echo -e "\nCOMP_CWORD=$COMP_CWORD"
    echo -e "\nCOMP_LINE=$COMP_LINE"
    echo -e "\ncur=$cur"
    fi

    # First time to complete or nothing with bd
    if [ -z "$cur" ] ;then
        cur=0
        # Reset the global vars
        _bd_comp_last_max_index=256
        case $complete_solution in
            "1")
                # Solution 1. Use the n_dir to display the folder
                COMPREPLY=( "1_$PWD" )
                return
                ;;
            "2")
                echo
                ;;
        esac
    fi

    local i=${cur}
    local j=$(expr ${i} + 1 )
    local nextIndex=${j}

    local targetPath="$PWD"
    local targetPathWithColor="$targetPath"

    if [ "$complete_solution" = "2" ] ; then
        if [ $(expr ${nextIndex} '>' ${limitCount} ) = 1 ] ; then
            nextIndex=$limit
            j=$limit
        fi
    fi

    # To prompt user which folder you may intent to go backword
    while [ $(expr ${j} '>' 0) = 1 ]
    do
        # Higher performance, no need to deal the words if they touched
        # the root /, current input number is higher then max
        if [ $(expr ${j} '>' ${_bd_comp_last_max_index}) = 1 ] ; then
            return 0
        fi

        # Make /a/b/c -> /a/b
        targetPath="${targetPath%/*}"
        local parent="${targetPath%/*}"
        local current="${targetPath##*/}"
        if [ "$BASHRC_SUPPORTS_COLOR" = yes ] ; then
            targetPathWithColor="\033[01;34m$parent/\033[01;32m$current\033[00m"
        else
            targetPathWithColor=$targetPath
        fi

        # j--
        j=$(expr ${j} - 1)

        # Reach the root now, record the index, if next input number
        # is higher than the max, return directly
        if [ -z "$targetPath" ] ; then
            _bd_comp_last_max_index=${nextIndex}
            targetPath="/"
            j=0
        fi
    done

    case $complete_solution in
        "1")
            # Solution 1. Use the n_dir to display to bd parameter and folder
            COMPREPLY=( "${nextIndex}_$targetPath" )
            ;;
        "2")
            # Solution 2. Show prompt with echo
            COMPREPLY=( "$nextIndex" )
            echo -n -e "\033[K\r\t\t$targetPathWithColor <<<\r \t>>>\r"
            # echo -n -e "\n\r\t\t$targetPathWithColor <<<\r \t>>>\r"
            if [ $(expr ${nextIndex} '>' ${limitCount} ) = 1 ] ; then
                echo -n -e "\n\tReached the limit ($limit), please press ENTER or shrink the number\r"
                COMPREPLY=( "9" )
            fi
            ;;
        *)
            ;;
    esac
}

complete -o nospace -F _bd bd

_getip()
{
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local available_devices=`get_available_inet_devices`
    COMPREPLY=( $(compgen -W "${available_devices}" -- "${cur}") )
}

complete -o nospace -F _getip getip
