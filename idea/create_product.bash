#!/bin/bash

function add_product()
{
    add_product_use_include $@
}

function add_product_use_include()
{
    local origin="$1"
    local new="$2"
    local feature="$3"

    # new product
    echo "DEBUG: locating dir"
    local project_root=$(find_droid_space_root)
    pushd $project_root
    echo "DEBUG: go project root $project_root"
    local origin_full_path=$(find device/ -name ${origin}.mk)
    local product_dir=$(dirname $origin_full_path)
    pushd $product_dir
    echo "DEBUG: found project dir and go $product_dir"

    echo "DEBUG: creating ${new}.mk"
    echo > "${new}.mk"

#    echo "DEBUG: printing \"include $origin_full_path\""
    echo "include $origin_full_path" >> "${new}.mk"
    
#    echo "DEBUG: printing empty line"
    echo >> "${new}.mk"

    # configure feature
    echo "PRODUCT_REVISION := $feature" >> "${new}.mk"
    echo "include \$(APPLY_PRODUCT_REVISION)" >> "${new}.mk"
    echo >> "${new}.mk"

#    echo "DEBUG:"
    echo "# Override" >> "${new}.mk"
    echo "PRODUCT_NAME := $new" >> "${new}.mk"

    # configuration AndroidProducts.mk
    echo -e "" >> AndroidProducts.mk
    echo 'PRODUCT_MAKEFILES += $(LOCAL_DIR)/'${new}.mk >> AndroidProducts.mk
    echo "#add_lunch_combo ${new}-userdebug" >> vendorsetup.sh

    echo "done"
    popd
    popd
    git status
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

function add_product_old_1()
{
    local origin="$1"
    local new="$2"
    local headerline="$3"

    # new product
    echo "DEBUG: locating dir"
    local product_dir=$(dirname $(find -name ${origin}.mk))
    pushd $product_dir
    echo "DEBUG: go $product_dir"
    echo -e $headerline > ${new}.mk
    echo "DEBUG: converting and create new product named ${new}.mk"
    sed -e "s?PRODUCT_NAME := $origin?PRODUCT_NAME := $new?g" ${origin}.mk >> ${new}.mk
    echo "DEBUG: creating has done, now configuring AndroidProducts.mk"

    # configuration AndroidProducts.mk
    echo -e "" >> AndroidProducts.mk
    echo 'PRODUCT_MAKEFILES += $(LOCAL_DIR)/'${new}.mk >> AndroidProducts.mk
    echo "#add_lunch_combo ${new}-userdebug" >> vendorsetup.sh

    echo "done"
    popd
    git status
}
