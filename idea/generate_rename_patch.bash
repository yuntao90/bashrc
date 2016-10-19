#!/bin/bash

function generate_patch()
{
    local patch_name="$@"
    git diff | sed -e "s?default.xml?$patch_name?g" > $patch_name.patch
}

export -f generate_patch

echo apply_default_patch is available

function apply_default_patch()
{
    ls | parallel generate_patch
    git checkout default.xml
    git apply *.patch
    git clean -df
    git add .
}
