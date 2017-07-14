
function copy_new_repo()
{
    local origin_dir="$1"
    local new_branch="$2"

    mkdir $new_branch
    cd $new_branch
    mkdir .repo
    cd .repo
    ln -s ../../$origin_dir/.repo/project-objects
    ln -s ../../$origin_dir/.repo/projects
    ln -s ../../$origin_dir/.repo/repo
    ln -s ../../$origin_dir/.repo/manifests.git
    cp -r ../../$origin_dir/.repo/manifests ./
    cp -r ../../$origin_dir/.repo/manifest.xml ./

    cd manifests
    git fetch origin
    git checkout -b repo_$new_branch origin/$new_branch
    git checkout repo_$new_branch
    cd ../../
}

echo "copy_new_repo [from_path] [new_branch] is available now"
