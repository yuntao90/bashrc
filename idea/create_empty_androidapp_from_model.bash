#!/bin/bash

LOCAL_PATH=$(dirname $0)

TARGET_APPLICATION_NAME=DefaultApplication
TARGET_PACKAGE_NAME=com.self.defaultapp
TARGET_ACTIVITY_NAME=DefaultActivity
TARGET_ACTIVITY_FILE_PATH=$(echo $TARGET_PACKAGE_NAME | sed -e "s?\.?\/?g")/$TARGET_ACTIVITY_NAME.java

cp -r $LOCAL_PATH/create_android_app_model ./$TARGET_APPLICATION_NAME
mkdir -p $(dirname ./$TARGET_APPLICATION_NAME/src/$TARGET_ACTIVITY_FILE_PATH)
mv ./$TARGET_APPLICATION_NAME/DefaultActivity.java ./$TARGET_APPLICATION_NAME/src/$TARGET_ACTIVITY_FILE_PATH
sed -e "s?%APPLICATION_NAME%?$TARGET_APPLICATION_NAME?g" -i `find $TARGET_APPLICATION_NAME/ -type f`
sed -e "s?%ACTIVITY_NAME%?$TARGET_ACTIVITY_NAME?g" -i `find $TARGET_APPLICATION_NAME/ -type f`
sed -e "s?%PACKAGE_NAME%?$TARGET_PACKAGE_NAME?g" -i `find $TARGET_APPLICATION_NAME/ -type f`

unset LOCAL_PATH
unset TARGET_APPLICATION_NAME
unset TARGET_PACKAGE_NAME
unset TARGET_ACTIVITY_NAME
unset TARGET_ACTIVITY_FILE_PATH