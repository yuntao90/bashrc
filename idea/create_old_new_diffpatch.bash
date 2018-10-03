#!/bin/bash

function cgitdir()
{
    local HERE=$PWD
    local T

    while [ "$PWD" != "/" ] ; do
        T=$PWD
        if [ -d "$T/.git" ] ; then
            cd $T
            return
        fi
        cd ..
    done
    echo "Failed to find .git"
    cd $HERE
}

function create_old_new_diff_patch()
{
    local patch_revision=$(git rev-parse --verify $1 2> /dev/null)

    if [ -z "$patch_revision" ] ; then
        echo "No revision passed in parameter 1, or not valid revision"
        return
    fi

    cgitdir

    git checkout $patch_revision

    mkdir -p patch

    local file_list_tmp=`git show $patch_revision --oneline --numstat | awk '{print $3}'`

    local file_list f
    for f in $file_list_tmp ; do
        if [ -f "$f" ] ; then
            file_list="$file_list $f"
            mkdir -p patch/new/$(dirname $f)
            mkdir -p patch/old/$(dirname $f)
            cp $f patch/new/$(dirname $f)/.
        fi
    done

    git format-patch ${patch_revision}^

    mv 00*.patch patch/.

    git checkout ${patch_revision}^

    for f in $file_list ; do
        cp $f patch/old/$(dirname $f)/.
    done

    echo Done
}

echo create_old_new_diff_patch is available
