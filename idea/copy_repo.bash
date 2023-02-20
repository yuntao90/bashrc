#!/bin/bash

function copy_new_repo()
{
    local dry_run=false no_fetch=false link_projects=false

    while [[ $# -gt 0 ]] ; do
        case $1 in
        --no-fetch|-l)
            no_fetch=true
        shift;;
        --dry-run|-d)
            dry_run=true
        shift;;
        --link-projects|-ln)
            link_projects=true
            shift;;
        -*)
            echo "Not supported options: $1"
            return 1
            ;;
        *)
        break;;
        esac
    done

    local origin_dir=$1
    local new_branch=$2

    if [ -z "$origin_dir" -o -z "$new_branch" ] ; then
        echo FAILED: Some necessary parameters not defined:
        echo origin_dir=$origin_dir
        echo new_branch=$new_branch
        return -1
    fi

    if $dry_run ; then
        echo Only print variables, not support print raw command currently
        echo origin_dir=$origin_dir, new_branch=$new_branch, no_fetch=$no_fetch
        return 0
    fi

    mkdir $new_branch
    cd $new_branch
    mkdir .repo
    cd .repo
    echo Linking .repo/project-objects ...
    ln -s ../../$origin_dir/.repo/project-objects

    if $link_projects ; then
        ln -s ../../$origin_dir/.repo/projects
    else
        # Use cp -rd , do not link to original dir, and
        # --force-sync maybe work in future, otherwise
        # it will be affect the original one.
        echo Copying .repo/projects ...
        cp -rd ../../$origin_dir/.repo/projects ./
    fi

    echo Linking other related files ...
    ln -s ../../$origin_dir/.repo/repo
    ln -s ../../$origin_dir/.repo/manifests.git
    cp -r ../../$origin_dir/.repo/manifests ./
    cp -r ../../$origin_dir/.repo/manifest.xml ./

    cd manifests
    echo Fetching origin to check updates ...
    if ! $no_fetch ; then
        git fetch origin
    fi
    echo Creating new brach for tracking origin/$new_branch ...
    git checkout -b repo_$new_branch origin/$new_branch
    git checkout repo_$new_branch
    cd ../../
    echo All done.
}

print_if_bashrc_ready "copy_new_repo [options...] <from_path> <new_branch> is available now"
