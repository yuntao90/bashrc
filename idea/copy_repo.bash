
function copy_new_repo()
{
    local origin_dir="$1"
    local new_branch="$2"

    mkdir $new_branch
    cd $new_branch
    mkdir .repo
    cd .repo
    echo Linking .repo/project-objects ...
    ln -s ../../$origin_dir/.repo/project-objects
#    ln -s ../../$origin_dir/.repo/projects

    # Use cp -rd , do not link to original dir, and
    # --force-sync maybe work in future, otherwise
    # it will be affect the original one.
    echo Copying .repo/projects ...
    cp -rd ../../$origin_dir/.repo/projects ./

    echo Linking other related files ...
    ln -s ../../$origin_dir/.repo/repo
    ln -s ../../$origin_dir/.repo/manifests.git
    cp -r ../../$origin_dir/.repo/manifests ./
    cp -r ../../$origin_dir/.repo/manifest.xml ./

    cd manifests
    echo Fetching origin to check updates ...
    git fetch origin
    echo Creating new brach for tracking origin/$new_branch ...
    git checkout -b repo_$new_branch origin/$new_branch
    git checkout repo_$new_branch
    cd ../../
    echo All done.
}

echo "copy_new_repo [from_path] [new_branch] is available now"
