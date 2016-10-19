
# Bashrc plus

## INSTALLATION
source install.bash at the bashrc directory

---

## COMPONENTS
This bashrc is gathered from:
bashrc.bash     [The entrance and some basic functions]
droid.bash      [The android related tools]
local\_env.bash [Not tracked by the git, customize user local script here, those modifyings will not be tracked by git]
ideas           [Scripts in folder idea/, the functions is too 'young', just an idea, not common, or under researching.
                 Dangerous or bad experience or unexpected result may occur. So put them into idea]

---

## FUNCTIONS

* In bashrc.bash:
bd          Back directory, against cd
            Usage:
            bd [number]

                    number: Optional, how many directories you want to go back.

            Notice:
                It supports completion now, input bd and a space, then press TAB, you can see the target path,
                if you want to pop up more, press TAB continuely.

psfgrep     Alias of ps -ef | grep
sfind       Alias of find . | grep
loop-do     Do something in dead loop
proxy\_set  Set the http\_proxy https\_proxy HTTP\_PROXY HTTPS\_PROXY in batch.
            Usage:
            proxy\_set [proxy_address]

                    proxy_address: the proxy delegate addresss you set, null means unset
ccd         cd and ls -alF
getip       Get the IP(v4) address, default parameter is eth0.
drop\_cache Drop the memory cache, free the file cache to get more PSS.
getremotecallerip   If you login the terminal into some remote PC, use this to try to get the caller IP.

* In droid.bash:

adb.bash            The bash completion from AOSP
adbroot             Alias for root - wait-for-device - remount
adb-restart-server  Restart adb server and run adb devices

logcatee            Alias of adb logcat -v threadtime | tee $HOME/droid.logcatee.log,
                    print log at screen and record them to disk at same time.
logcatdump          Alias of adb logcat -d -v threadtime | tee $HOME/droid.logcatdump.log ; vim $HOME/droid.logcatdump.log
                    dump logcat (dump log not block thread) at screen and to local, and then, use vim to visit the local one.

droid\_dump         Alias of adb shell dumpsys
droid\_am\_dump     Alias of adb shell dumpsys activity
droid\_am\_focused  Find out the focused activity on device
droid\_proc\_pid    Find the pid of the process name you pass. And cat the file in proc/[pid]/[file], file is optional parameter,
                    if you put, the file will be cat.
droid\_proc\_stat   Find the pid or process name stat, and parsed them with human-readable. second parameter is the one of
                    the stat name or the position you want to query. See the man proc and find proc/[pid]/stat introduction.
droid\_proc\_signal Find the process by name you pass in param1, and send kill -SIGNAL to process you pass in param2.
droid\_proc\_kill   Find the process by name you pass and kill it
droid\_proc\_quit   Find the process by name you pass and send signal 3

droid\_build\_init  Init the build environment, the parameter is the project you want to lunch, if pass nothing at
                    first time in current code project directory, you can choose one, and he will remember your
                    choice, we *strongly recommended* you use the [product]-[userdebug/user/eng] instead of a number.
                    This function will try efforts as follow:
                        source build/envsetup.sh
                        lunch [the project] or read from .lunch_config
                        export TOP <- Can call mm and croot outside of current code space.
                        use c cache <- Recommended in source.android.com
                        raise jack server heap size <-  From AndroidN, raise the heap size for jack-server, default is 3/4
                                                        of total PSS in PC, you can override it by default use env
                                                        DEFAULT_JACK_SERVER_HEAPSIZE (ex. =6144m).

droid\_build\_init7         Use the openjdk7 to lunch the product
droid\_build\_init8         Use the openjdk8 to lunch the product
droid\_build\_init\_compat  [Recommended] lunch the product, let the scripts determine the java version

After droid\_build\_init, you can use:
pushapp             Auto detect the app and push them into device
pushmodule          Not completed yet.
pushinstall         Use mm | parallel pushinstall, and push everything in output starts with Install: out/


* Idea:
copy\_repo          For AOSP repository, copy a new branch of code from original one, with most space saving functions.
                    Actually, the copy is fake, link .repo/project-objects .repo/projects .repo/repo .repo/manifests.git
                    to the new folder, copy .repo/manifests to it. And then, objects from remote will be shared, but
                    because of local branch is different, the new code and old one will not effect each other.

                    Usage:
                    copy_new_repo [from_folder] [new_branch_in_manifest]

                            from_folder: the old foler you want to copy from [**CAUTION: the old folder must not be deleted **]
                            new_branch_in_manifest: the branch you want to copy must come from .repo/manifests

gerrit              NOT PUBLIC, you can try and learn gerrit shell port
                    like ssh -p 29418 username@android-review.googlesource.com gerrit
