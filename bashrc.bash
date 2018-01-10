#!/bin/bash

# ----- built-in for Ubuntu -----
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

BASHRC_PLUS_DIR=$(dirname $MY_BASHRC_PLUS)

# Define it earlier for better.
# use which to locate the linux command
function has_command()
{
    local validate_command="$1"
    local validate_result=`type -t $validate_command`

    if [ -n "$validate_result" ] ; then
        return 0
    fi
    return 1
}

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

function get_value()
{
    local name="$1"
    local value
    eval value=\$$name
    echo "$value"
}

function dump_value()
{
    local name="$1"
    local value
    eval value=$(get_value $name)
    echo "$name = $value"
}

# Param 1 : ENV_NAME
# Param 2 : ENV_VALUE
function check_env_and_print()
{
    local name="$1"
    local value=$(get_value $name)

    if [ -n "$name" ] ; then
#        echo $name=$value
        if [ -z "$value" ] ; then
            echo -e "\033[34m$name\033[0m is not set"
        fi
    fi

}

# disable git ps1 displaying, make it open manually.
# if [ -z "$PROMPT_COMMAND" ] ; then
# PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\$ "'
# fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi



function is_number_only()
{
    local input="$@"
    # dump_value input
    if [ -n "$input" ] ; then
        local filter_result="$(echo $input | egrep -o '[0-9]*')"
        # dump_value filter_result
        if [ "$filter_result" = "$input" ] ; then
            return 0
        fi
    fi
    return 1
}

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# ------------------------------

DROID_BASHRC=$BASHRC_PLUS_DIR/droid.bash

# load bash completion
MY_BASH_COMPLETION=$BASHRC_PLUS_DIR/bash_completion/bash_completion

if [ -f "$MY_BASH_COMPLETION" ] ; then
    source $MY_BASH_COMPLETION
fi

function check_bashrc_env()
{
    if [ -f "$LOCAL_ENV_BASHRC" ] ; then
        source $LOCAL_ENV_BASHRC
    else
        echo -e "\n\033[34mNotice: \033[32mYou can edit your private env into \033[33m$LOCAL_ENV_BASHRC\033[32m, that file can be ignored to git\033[0m\n"
    fi

    if [ -z "$ANDROID_SDK" ] ; then
        echo -e "\n\033[34mNotice: \033[32mCan not found ANDROID_SDK, you can set it into \033[33m$LOCAL_ENV_BASHRC\033[0m"
    fi

    echo -e "\nOther suggested env:"
    check_env_and_print DEFAULT_ADDITIONAL_DISPLAY_DEVICE
    check_env_and_print DEFAULT_ADDITIONAL_DISPLAY_X
    check_env_and_print DEFAULT_ADDITIONAL_DISPLAY_Y
    check_env_and_print DEFAULT_JACK_SERVER_HEAPSIZE
}

if [ -f "$DROID_BASHRC" ] ; then
    source $DROID_BASHRC
fi

LOCAL_ENV_BASHRC=$BASHRC_PLUS_DIR/local_env.bash

check_bashrc_env

MY_BASHRC_FILES="$MY_BASHRC_PLUS $DROID_BASHRC $LOCAL_ENV_BASHRC"

function locate-recent-android-sdk-build-tools()
{
    local build_tools="$(ls $ANDROID_SDK/build-tools | grep -e ^[0-9] | xargs echo)"

    local space_count=$(expr $(expr $(echo ${build_tools} | grep -o " " | wc -m) / 2) + 1)

    echo $build_tools | cut -d " " -f $space_count
}

# alias the android-tools
if [ -n "$ANDROID_SDK" ] ; then
    export PATH=$ANDROID_SDK/platform-tools:$ANDROID_SDK/tools:$PATH
# $ANDROID_SDK/build-tools/*/ <- TODO how can we include this?
# TODO temp solution
    export PATH=$ANDROID_SDK/build-tools/$(locate-recent-android-sdk-build-tools ):$PATH
else
    echo -e "\n\033[34mNotice: \033[32mCan not found ANDROID_SDK, you can set it into \033[33m$LOCAL_ENV_BASHRC\033[0m"
fi

# alias quick grep
alias psgrep='ps | grep'
alias psfgrep='ps -ef | grep'

# alias quick ps
alias psall='ps -ef'

if has_command setsid ; then
# alias gitk and gedit as new process
alias gitk='setsid gitk'
alias gedit='setsid gedit'
fi

# Quick reload .bashrc
alias reloadbash='source ~/.bashrc'

# Alias sfind, it will find file easily
function sfind()
{
    local find_options="."
    local grep_options="$@"
    find $find_options | grep $grep_options
}

# TODO, for more platforms
if [ -z "$DEFAULT_SFIND_SELECT_VIEWER" ] ; then
    DEFAULT_SFIND_SELECT_VIEWER="vi"
fi

function sfind-select()
{
    local selections
    local sfind_options="$@"
    local index=0
    local selector selectors print_items
    # Run sfind $@, and collect results.
    local results=`sfind $sfind_options`
    # Ensure the results was right.
    if [ -z "$results" ] ; then
        echo "sfind $sfind_options got nothing"
        return
    fi

    echo
    # Put the sfind results into array and print them.
    selections=( $results )
    for selector in $results ; do
        print_items="$print_items  $index\t$selector\n"
        index=$(( $index + 1 ))
    done
    if [ "$index" = "1" ] ; then
        # If only one item was found, open it directly.
        echo -e "sfind [$sfind_options] only found\n\n  \t$results\n\nuse [$DEFAULT_SFIND_SELECT_VIEWER] to open\n"
        $DEFAULT_SFIND_SELECT_VIEWER $results
        return
    else
        echo -e "sfind [$sfind_options] found $index items\n"
        print_items="$print_items  $index\tall of them"
    fi
    echo -e "$print_items"
    echo

    # Wait for user input.
    echo -n "Which files would you want to view with [$DEFAULT_SFIND_SELECT_VIEWER] ? "
    read selector
    # echo "User input $selector"
    if [ -z "$selector" ] ; then
        echo "Invalid input"
        return
    fi

    # User said all of them.
    if [ "$selector" = "$index" ] ; then
        # echo "Open all of them"
        $DEFAULT_SFIND_SELECT_VIEWER $results
        return
    fi

    # If user input much more files, try to collect them all.
    selectors=( $selector )
    results=""
    for selector in ${selectors[*]} ; do
        # echo "Iterating now is $selector"
        # echo "Selecting $selector ..."
        # dump_value selector
        if is_number_only $selector ; then
            # If input is only numbers, then parse in selections
            results="${selections[selector]} $results"
        else
            # Or not a number, maybe a path, to assume if exists and open it.
            if [ -f "$selector" ] ; then
                results="$selector $results"
            fi
        fi
    done
    # echo "executing $DEFAULT_SFIND_SELECT_VIEWER $results"
    $DEFAULT_SFIND_SELECT_VIEWER $results
}
# function sfind()
# {
#    find -iwholename *$1* | grep $1
# }

#------------------------------transport or login with remote system or server
# Where remotes

# back directories
function bd()
{
local localLOGV="false"
local _MAX_LEVEL_LIMIT=64
if [ $localLOGV = "true" ] ; then
    echo "Back directory in verbose mode"
    echo "Input params: " $@
fi

if [ ! $1 ] ; then
    if [ $localLOGV = true ] ; then
        echo "None of params, treat as cd .."
    fi
    cd ..
else
    local popLevel=$(filter_numbers $1)
    if [ -z "$popLevel" ] ; then
        echo "bd: Bad input $@, expect number"
        return
    fi
    local popString="."
    if [ $localLOGV = true ] ; then
        echo "Parsed popLevel = ""\"${popLevel}\""
    fi
    if [ $(expr ${popLevel} '>' ${_MAX_LEVEL_LIMIT}) -eq 1 ] ; then
        echo "Warning: pop level > $_MAX_LEVEL_LIMIT"
        cd /
        return
    fi
    while [ $(expr ${popLevel} '>' 0) -eq 1 ]; do
        popString=$popString"/.."
        popLevel=$(expr ${popLevel} - 1)
    done
    if [ $localLOGV = true ] ; then
        echo "final command = cd $popString"
    fi
    cd $popString
fi
}

#-------------------------------------------------------------------------------

# Alias quick enable-disable touchpad
alias touchpad-enable='sudo modprobe psmouse'
alias touchpad-disable="sudo rmmod psmouse"

# Edit me easily
alias bashrc-reload='. $HOME/.bashrc'
if has_command gedit ; then
alias gedit-bashrc='gedit $MY_BASHRC_FILES; bashrc-reload'
fi
alias vim-bashrc='vim $MY_BASHRC_FILES; bashrc-reload'

if has_command gedit ; then
function gedit-sfind()
{
    gedit `sfind $1`
}
fi

alias fastboot='sudo `which fastboot`'

function set-color-disable
{
    alias grep='`which grep`'
    alias ls='`which ls`'
}

function set-color-enable
{
    alias grep='grep --color=auto'
    alias ls='ls --color=auto'
}

function loop-do()
{
    while [ true ] ;
    do
        $@
    done
}

#notify-send --urgency=low "User logined" "\n`ps`"

if has_command gedit ; then
alias gedit_wait="`which gedit` --wait"
fi

# Set this process proxy
function proxy_set()
{
    if [ -n "$1" ] ; then
        export http_proxy="$1"
        export https_proxy="$1"
        export HTTPS_PROXY="$1"
        export HTTP_PROXY="$1"
    else
        unset http_proxy
        unset https_proxy
        unset HTTP_PROXY
        unset HTTPS_PROXY
    fi
}

# Go directory and run ll
function ccd()
{
    cd "$@"
    ls -alhF
}

# Only for myself, Deprecated
function vga_new_mode()
{
    local x="$1"
    local y="$2"
    local modeline=`cvt  $x $y | sed -e "s?#.*??g" | sed -e "s?Modeline ??g" | xargs echo`
    local modename=`echo $modeline | cut -d " " -f 1`
    sudo xrandr --newmode $modeline
    echo $modename
}

# Param 1 : Display Device, default=VGA1 or DEFAULT_ADDITIONAL_DISPLAY_DEVICE
# Param 2 : X resolution, default=1680 or DEFAULT_ADDITIONAL_DISPLAY_X
# Param 3 : Y resolution, default=1050 or DEFAULT_ADDITIONAL_DISPLAY_Y
# or
# Param 1 : Display Device, default=VGA1 or DEFAULT_ADDITIONAL_DISPLAY_DEVICE
# Param 2 : modename added previously
function vga_add_mode()
{
    local display_device="$DEFAULT_ADDITIONAL_DISPLAY_DEVICE"
    local x y
    local modename

    # Check parameters
    if [ -z "$display_device" ] ; then
        display_device="$DEFAULT_ADDITIONAL_DISPLAY_DEVICE"
        if [ -z "$display_device" ] ; then
            display_device="VGA1"
        fi
    fi

    if [ -n "$2" ] ; then
        if is_number_only "$2" ; then
            x="$2"
            y="$3"
        else
            modename="$2"
        fi
    fi

    if [ -z "$modename" ] ; then
        if [ -z "$x" ] ; then
            x="$DEFAULT_ADDITIONAL_DISPLAY_X"
            if [ -z "$x" ] ; then
                x="1680"
            fi
        fi

        if [ -z "$y" ] ; then
            y="$DEFAULT_ADDITIONAL_DISPLAY_Y"
            if [ -z "$y" ] ; then
                y="1050"
            fi
        fi

        modename=$(vga_new_mode $x $y)
    fi

    echo "Add modename [$modename] into device [$display_device]"
    sudo xrandr --addmode "$display_device" $modename
}

function get_available_inet_devices()
{
    ifconfig | grep ^[a-zA-Z0-9] | awk '{print $1}'
}

# Get the simple ip address instead of ifconfig. Only support for ipv4.
# param 1 - device : the device you want to parse the ip address, default is eth0
function getip()
{
    local inet_line maybe_address splitter device="$(echo `get_available_inet_devices` | awk '{print $1}')"
    if [ -n "$1" ] ; then
        device="$1"
    fi
    inet_line="$(ifconfig "$device" | grep "inet ")"
    if [ -n "$(echo $inet_line | grep -o ":")" ] ; then
        splitter=":"
    else
        splitter=" "
    fi
    maybe_address="$(echo $inet_line | cut -d "$splitter" -f 2)"
    echo $maybe_address | grep -o "[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}"
}

# If this tty is logined from remote, find its ip address
function getremotecallerip()
{
    who | grep "$(ps | grep bash | cut -d " " -f 2)" | grep -o \(.*\) | sed -e "s?(??g" | sed -e "s?)??g"
}

# Deprecated
function getnameip()
{
    local username="`whoami`"
    if [ -n "$1" ] ; then
        username="$1"
    fi
    local device="eth0"
    if [ -n "$2" ] ; then
        device="$1"
    fi
    
    echo $username"@"$(getip $device)
}

function drop_cache()
{
    case `uname -s` in
        Darwin)
            echo "Before drop_cache, memory_pressure was:"
            memory_pressure
            sync
            sudo purge
            echo "Drop cache was done, after drop cache"
            memory_pressure
        ;;
        *)
            echo "Before drop_cache, free -m was:"
            free -m
            sudo sysctl vm.drop_caches=3
            sleep 1
            sudo sysctl vm.drop_caches=1
            echo "Drop cache was done, after drop cache"
            free -m
        ;;
    esac
}
# From grep -n or beagrep, result like /file/name:2:grep results.
# This result can not pass into editor directly, so parse them.
function parse_path_and_line()
{
    local line_full=$@
    local file_name=$(echo $line_full | cut -d : -f 1)
    local line_number=$(echo $line_full | cut -d : -f 2| egrep -o ^[0-9].)
    echo "$file_name +$line_number"
}

function calculate_total_mem()
{
    free -m | grep Mem: | xargs -n 2 | grep Mem: | cut -f 2 -d " "
}

function filter_numbers()
{
    echo "$@" | grep -o ^[0-9]*
}

GIT_PS1_PROMPT_COMMAND='__git_ps1 "\u@\h:\w" "\\\$ "'

# alpha version
function git_ps1_enable()
{
    if [ -z "$PROMPT_COMMAND" ] ; then
        PROMPT_COMMAND="$GIT_PS1_PROMPT_COMMAND"
    else
        if [ -z "`echo $PROMPT_COMMAND | grep $GIT_PS1_PROMPT_COMMAND`" ] ; then
            PROMPT_COMMAND="$PROMPT_COMMAND;$GIT_PS1_PROMPT_COMMAND"
        fi
    fi
}

function git_ps1_disable()
{
    PROMPT_COMMAND=$(echo $PROMPT_COMMAND | sed -e "s?$GIT_PS1_PROMPT_COMMAND??g")
}

if [ -d "$HOME/tools/bin" ] ; then
    export PATH=$HOME/tools/bin:$PATH
fi
