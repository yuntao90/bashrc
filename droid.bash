#!/bin/bash

ADB_BASHRC=$(dirname $MY_BASHRC_PLUS)/adb.bash
DEFAULT_JACK_SERVER_VM_ARGUMENTS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation"

source $ADB_BASHRC

# run traceview with a new thread
alias traceview='setsid traceview'

# DDMS
alias android-device-monitor='setsid monitor'

# alias the adb command of rooting then remounting
alias adbroot='adb devices; adb wait-for-device ; adb root; adb wait-for-device; adb remount'

alias parse-apk-name='echo `cat $(findmakefile) | grep LOCAL_PACKAGE_NAME |egrep -o "= .*" | egrep -o "[A-Za-z0-9].*" `'

alias parse-assume-priv-app='cat $(findmakefile) | grep LOCAL_PRIVILEGED_MODULE | egrep -o "= .*" | egrep -o "[A-Za-z0-9].*"'

# Alias adb-restart-server
alias adb-restart-server='sudo adb kill-server ;sudo `which adb` start-server; adb devices'

# Alias android 4.1 Compatibility-Test-Suite
#alias cts-4.2='. /home/apuser/4.1cts/tools/cts-tradefed'

# Make backups in framework before push.
function backupframework()
{
    adb shell 'busybox cp /system/framework/framework-res.apk /data/local/tmp/'
    adb shell 'busybox cp /system/framework/framework.jar /data/local/tmp/'
    adb shell 'busybox cp /system/framework/framework2.jar /data/local/tmp/'
    adb shell 'busybox cp /system/app/FrameworkRes.apk /data/local/tmp/'
}
# Remove frameworks intermediates easily.

function rmframework()
{
    echo "Clearing framework-res"
    rm -r $(gettop)/out/target/common/obj/APPS/framework-res_intermediates/
    echo "Clearing framework-base"
    rm -r $(gettop)/out/target/common/obj/JAVA_LIBRARIES/framework-base_intermediates/
    echo "Clearing framework"
    rm -r $(gettop)/out/target/common/obj/JAVA_LIBRARIES/framework_intermediates/
    echo "Clearing framework2"
    rm -r $(gettop)/out/target/common/obj/JAVA_LIBRARIES/framework2_intermediates/
#    echo "Clearing framework-res-vendor"
#    rm -r $(gettop)/out/target/common/obj/APPS/FrameworkRes_intermediates/
}

function mmframeworks()
{
    local _modules="\
    frameworks/base/core/res \
    frameworks/base \
    frameworks/base/services \
    frameworks/base/services/java \
    frameworks/base/policy \
    frameworks/base/packages/Keyguard \
    frameworks/base/packages/SystemUI
    "
    local _jobs="4"
    #echo "make $_modules with $_jobs jobs"
    mmm $_modules -kj$_jobs
}

function pushinstall()
{
    local input="$@"
    if [ -n "$(echo $input | grep ^out/)" ] ; then
        pushmodule $input
        return 0
    fi
    local installed=`echo $@ | grep "^Install: " | sed -e "s?Install: ??g"`
    echo $input
    if [ -n "$installed" ] ; then
        local full_installed=$ANDROID_BUILD_TOP/$installed
#        echo "DEBUG: OUT is $OUT"
        local target=$(echo $full_installed |sed -e "s?$OUT??g")
        echo "Pushing $full_installed to $target"
        adb push $full_installed $target
    fi
}

export -f pushinstall

# Push frameworks easily
function pushframework()
{
    adbroot
#    backupframework
    echo "Pushing framework-res.apk"
    adb push $OUT/system/framework/framework-res.apk /system/framework
    echo "Pushing framework.jar"
    adb push $OUT/system/framework/framework.jar /system/framework
    echo "Pushing framework2.jar"
    adb push $OUT/system/framework/framework2.jar /system/framework
    echo "Pushing ext.jar"
    adb push $OUT/system/framework/ext.jar /system/framework
#    adb push ../app/FrameworkRes.apk /system/app
#    adb reboot
}

function pushcore()
{
    adbroot
    echo "Pushing core.jar"
    adb push $OUT/system/framework/core.jar /system/framework/
    echo "Pushing core-libart.jar"
    adb push $OUT/system/framework/core-libart.jar /system/framework
}

function pushframeworkpolicy()
{
    echo "Pushing android.policy.jar"
    adb push $OUT/system/framework/android.policy.jar /system/framework/
}

function pushframeworkservice()
{
    echo "Pushing services.jar"
    adb push $OUT/system/framework/services.jar /system/framework/
}

function pushserviceandpolicy()
{
    pushframeworkservice
    pushframeworkpolicy
}

function pushframeworkabouts()
{
#    pushcore
    pushframework
    pushserviceandpolicy
    adb reboot
}

function pushcoreabouts()
{
    pushcore
    pushframeworkabouts
}

function pushapp()
{
    local APK
    if [ ! $1 ] ; then
        APK=$(parse-apk-name)
    else 
        APK=$1
    fi
    
    if [ -z "$APK" ] ; then
        echo "Nothing to push, parsed apk is empty"
        return
    fi

    if [ $(parse-assume-priv-app) ] ; then
        # After 5.0 folder changed to system/priv-app/ApkName/ApkName.apk
        # make compatibility
        if [ -d "$OUT/system/priv-app/$APK" ] ; then
            # ensure dir exists
            `which adb` shell mkdir -p /system/priv-app/$APK
            APK="$APK/${APK}.apk"
        else
            APK="${APK}.apk"
        fi
        echo "Pushing $OUT/system/priv-app/$APK to /system/priv-app/$APK"
        `which adb` push $OUT/system/priv-app/$APK /system/priv-app/$APK
    else
        if [ -d "$OUT/system/app/$APK" ] ; then
            `which adb` shell mkdir -p /system/app/$APK
            APK="$APK/${APK}.apk"
        else
            APK="${APK}.apk"
        fi
        echo "Pushing $OUT/system/app/$APK to /system/app/$APK"
        `which adb` push $OUT/system/app/$APK /system/app/$APK
    fi

}

# init build tools and lunch product, set TOP, only take effect on the root of code space
function droid_build_init()
{
    # PROMPT_COMMAND override - ALPHA , not completed.
    if [ -z "${PROCESS_GLOBAL_PROMPT_COMMAND}" ] ; then
        PROCESS_GLOBAL_PROMPT_COMMAND=$PROMPT_COMMAND
    fi

    # Record current path and find the root of code space.
    local local_path=`pwd`
    local project_root=$(find_droid_space_root)

    # Record the path of adb, and workaround for the different adb version issues.
    local origin_adb_path=`which adb`

    # Go the code space root.
    cd $project_root

    # AOSP processing
    source build/envsetup.sh

    # Smart lunching
    local lunch_project="$1"

    if [ -n "$lunch_project" ] ; then
        lunch $lunch_project
        echo $lunch_project > .lunch_config
    else
        lunch_project=`cat .lunch_config`
        lunch $lunch_project

        # ok, if you lunch project with the function lunch without parameters,
        # record what you input in lunch into .lunch_config,
        # first time calling may cause this.
        if [ -z "$lunch_project" ] ; then
            lunch_project=`get_build_var TARGET_PRODUCT`-`get_build_var TARGET_BUILD_VARIANT`
            echo $lunch_project > .lunch_config
        fi
    fi

    # PROMPT_COMMAND override - ALPHA , not completed
    if [ -n "${PROCESS_GLOBAL_PROMPT_COMMAND}" ] ; then
        if [ "${PROCESS_GLOBAL_PROMPT_COMMAND}" != "$PROMPT_COMMAND" ] ; then
            # the PROMPT_COMMAND was modified, restore it. - ALPHA version
            PROMPT_COMMAND="$PROMPT_COMMAND;${PROCESS_GLOBAL_PROMPT_COMMAND}"
        fi
    fi

    # Define the TOP, croot and mm can be used outside of code space.
    export TOP=`pwd`

    # Use c cache as source.android.com recommended.
    droid_use_ccache

    # Go back to the caller path.
    cd $local_path

    # Workaround for the different adb version promblem.
    export PATH=$(dirname $origin_adb_path):$PATH

    # Find jack and raise jack heap size.
    local whereisjack="$(type -t jack)"
    if [ -n "$whereisjack" ] ; then
        local jack_version=`jack --version | grep Version:`
        if [ -n "$jack_version" ] ; then
            droid_override_jackserver_heapsize
        fi
    fi
}

function jack-restart-server()
{
    jack-admin stop-server
    jack-admin start-server
}

function droid_override_jackserver_heapsize()
{
    local new_size=$@

    if [ -z "$new_size" ] ; then
        new_size=$DEFAULT_JACK_SERVER_HEAPSIZE
    fi

    if [ -z "$new_size" ] ; then
        new_size="$(expr $(expr `calculate_total_mem` \/ 4) \* 3)m"
    fi

    export JACK_SERVER_VM_ARGUMENTS="$JACK_SERVER_VM_ARGUMENTS $DEFAULT_JACK_SERVER_VM_ARGUMENTS -Xmx$new_size"
    echo "Resize jack heap size to $new_size , and restart jack server"
    jack-restart-server
}

function find_droid_space_root()
{
    local default_path=`pwd`
    local target_path=$default_path
    while [ `pwd` != '/' ]
    do
        if is_droid_space_root
        then
            target_path=`pwd`
            cd $default_path
            echo $target_path
            return
        fi
        cd ../
    done
    echo `pwd`
}

function is_droid_space_root()
{
    if [ -d .repo ] ; then
        if [ -f Makefile ] ; then
            return 0
        fi
    fi
    return 1
}

function pdkprepare()
{
    export PDK_FUSION_PLATFORM_ZIP=vendor/pdk/mini_armv7a_neon/mini_armv7a_neon-userdebug/platform/platform.zip
    droid_build_init7 $@
}

function droid_build_initcompat()
{
    unset JAVA_HOME
    droid_build_init $@
}

# init the android build for java7
function droid_build_init7()
{
    export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64
    droid_build_init $@
}

function droid_build_init8()
{
    export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
    droid_build_init $@
}

# Tab completion for droid_build_init.
function _droid_build_init()
{
    if [ -z "$(type -t _lunch | grep function)" ] ; then
        local local_path=`pwd`
        local project_root=$(find_droid_space_root)
        if [ -d "$project_root" ] ; then
            cd $project_root
            source build/envsetup.sh
            cd $local_path
        fi
    fi

    _lunch $@
}

complete -F _droid_build_init droid_build_init
complete -F _droid_build_init droid_build_init7
complete -F _droid_build_init droid_build_init8
complete -F _droid_build_init droid_build_initcompat

function droid_use_ccache()
{
    export USE_CCACHE=1
    local local_ccache_path="$HOME/.ccache"
    if [ -n "$1" ] ; then
        local_ccache_path="$1"
    fi
    export CCACHE_DIR=$local_ccache_path
    $(gettop)/prebuilts/misc/linux-x86/ccache/ccache -M 50G
}

function droid_dump()
{
    adb shell dumpsys $@
}

function droid_am_dump()
{
    droid_dump activity $@
}

function droid_am_focused()
{
    echo "$(droid_am_dump)" | grep mFocusedActivity
}

function droid_proc_pid()
{
    local processname="$1"
    local procfile="$2"
    local pid
    pid=$(adb shell ps | grep $processname | xargs echo | cut -d " " -f2)
    if [ -n "$procfile" ] ; then
        adb shell cat /proc/$pid/$procfile
    else
        echo $pid
    fi
}

declare -a BASHRC_PROC_TYPES
BASHRC_PROC_TYPES=( \
        pid comm state ppid pgrp session tty_nr tpgid flags \
        minflt cminflt majflt cmajflt utime stime cutime cstime priority nice \
        num_threads itrealvalue starttime vsize rss rsslim startcode endcode \
        startstack kstkesp kstkeip signal blocked sigignore sigcatch wchan \
        nswap cnswap exit_signal processor rt_priority policy \
        delayacct_blkio_ticks guest_time cguest_time start_data end_data \
        start_brk arg_start arg_end env_start env_end exit_code \
)

function _droid_proc_stat_position_for_name()
{
    local position="$@"
    if [ -z "$position" ] ; then
        echo ${BASHRC_PROC_TYPES[*]}
        return 0
    fi

    position=$(( $position - 1 ))
    echo ${BASHRC_PROC_TYPES[$position]}
}

function _droid_proc_stat_name_for_position()
{
    local name="$@"

    if [ -z "$name" ] ; then
        echo ${BASHRC_PROC_TYPES[*]}
        return 0
    fi

    local position=0
    local proc_types_max="${#BASHRC_PROC_TYPES[@]}"
    while [ "$name" != ${BASHRC_PROC_TYPES[$position]} ]
    do
        position=$(( $position + 1 ))
        if [ $position = $proc_types_max ] ; then
            return 1
        fi
    done
    position=$(( $position + 1 ))
    echo $position
}

# To cat the device /proc/[pid]/stat and show all values or one of them.
# param 1: process name or pid
# param 2: one of the stats (Optional)
function droid_proc_stat()
{
    local pid_or_processname="$1"
    local pid processname
    local statposition_or_statkey="$2"
    local statposition statkey
    local result

    if [ -z "$pid_or_processname" ] ; then
        echo -e "droid_proc_stat [pid/processname] [stat position or name](Optional)"
        return 1
    fi

    pid="$(echo $pid_or_processname | grep -o [0-9].*)"
    if [ "$pid" = "$pid_or_processname" ] ; then
        result=`adb shell cat /proc/$pid/stat`
    else
        processname="$pid_or_processname"
        result=`droid_proc_pid $processname 'stat'`
    fi

    if [ -n "$statposition_or_statkey" ] ; then
        statposition="$(echo $statposition_or_statkey | grep -o [0-9].*)"
        if [ "$statposition" = "$statposition_or_statkey" ] ; then
            statkey="$(_droid_proc_stat_position_for_name $statposition)"
        else
            statkey="$statposition_or_statkey"
            statposition="$(_droid_proc_stat_name_for_position $statkey)"
        fi
        if [ -z "$statposition" ] ; then
            echo
            echo "Unknown key $statkey, print all key values"
            statposition_or_statkey=""
        else
            local value=$(echo $result | awk '{print $'$statposition'}')
            echo "$statkey ($statposition) : $value"
        fi
    fi

    if [ -z "$statposition_or_statkey" ] ; then
        echo
        echo "================="
        echo
        echo "Raw data:"
        echo
        echo ${BASHRC_PROC_TYPES[*]}
        echo $result
        echo
        echo "================="
        echo
        echo "Mapped values:"
        echo
        local value count
        if has_command tabs ; then
            tabs 24
        fi
        local output=""
        for value in $result ; do
            output="${output}${BASHRC_PROC_TYPES[$count]}: \t $value\n"
            count=$(( $count + 1 ))
        done
        echo -e $output
        if has_command tabs ; then
            tabs 8
        fi
    fi

}

# Send signal to the process you want to find
# Param1: The process name you want to find
# Param2: The signal you want to send
function droid_proc_signal()
{
    local processname="$1"
    local signal="$2"

    adb shell "kill -$signal $(droid_proc_pid $processname)"
}

function droid_proc_kill()
{
    droid_proc_signal "$@" 9
}

function droid_proc_quit()
{
    droid_proc_signal "$@" 3
}

function logcatee()
{
    local parameters="$@"
    local output="$HOME/droid.logcatee.log"

    local prompt="\nlogcat saved into $output\n"

    # trap the Ctrl+C command, and echo result
    trap "trap 2; echo -e $prompt" 2

    adb logcat -v threadtime $parameters | tee $output

    # Cancel trap because executing done.
    trap 2
    echo -e $prompt
}

function logcatdump()
{
    local parameters="$@"
    local output="$HOME/droid.logcatdump.log"

    local prompt="\nlogcat saved into $output\n"

    adb logcat -v threadtime -d $parameters | tee $output

    less $output

    echo -e $prompt
}

function repo-silent-sync()
{
    repo forall -c "git fetch" --all
}

function pushmodule()
{
    local module="$@"
    if [ -n "$(echo $module | grep ^out/)" ] ; then
        local full_path="$ANDROID_BUILD_TOP/$module"
        local target_path=$(echo $full_path | sed -e "s?$OUT??g")
        echo "Pushing $full_path to $target_path"
        adb push $full_path $target_path
    fi
}

# Temporary show the helpful message about how to download them
function droid_decode_tools_print()
{
    echo "Avaliable apk decode software, currently, download them yourself."
    echo "=============================================="
    echo -e "Smali/BackSmali\thttps://github.com/JesusFreke/smali.git"
    echo -e "jd-gui\thttp://jd.benow.ca/"
    echo -e "dex2jar\thttps://github.com/pxb1988/dex2jar"
    echo -e "apktool\thttps://ibotpeaches.github.io/Apktool/"
    echo "==============================================="
}
