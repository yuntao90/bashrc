#!/bin/bash

# ./gradlew clean

all_java_files=$(find -name '*.java')

sed -e 's?import androidx.annotation.NonNull;?import android.support.annotation.NonNull;?g' -i $all_java_files
sed -e 's?import androidx.collection.ArrayMap;?import android.support.v4.util.ArrayMap;?g' -i $all_java_files
sed -e 's?import androidx.collection.ArraySet;?import android.support.v4.util.ArraySet;?g' -i $all_java_files
sed -e 's?import androidx.collection.SimpleArrayMap;?import android.support.v4.util.SimpleArrayMap;?g' -i $all_java_files
sed -e 's?import androidx.collection.SparseArrayCompat;?import android.support.v4.util.SparseArrayCompat;?g' -i $all_java_files
sed -e 's?import androidx.core.util.Pools;?import android.support.v4.util.Pools;?g' -i $all_java_files
sed -e 's?import androidx.annotation.RequiresApi;?import android.support.annotation.RequiresApi;?g' -i $all_java_files
sed -e 's?import androidx.annotation.IntDef;?import android.support.annotation.IntDef;?g' -i $all_java_files
sed -e 's?import androidx.annotation.Nullable;?import android.support.annotation.Nullable;?g' -i $all_java_files
sed -e 's?import androidx.core.util.PatternsCompat;?import android.support.v4.util.PatternsCompat;?g' -i $all_java_files
sed -e 's?import androidx.core.view.MotionEventCompat;?import android.support.v4.view.MotionEventCompat;?g' -i $all_java_files
sed -e 's?import androidx.customview.widget.ViewDragHelper;?import android.support.v4.widget.ViewDragHelper;?g' -i $all_java_files
sed -e 's?import androidx.core.util.AtomicFile;?import android.support.v4.util.AtomicFile;?g' -i $all_java_files
sed -e 's?import androidx.core.util.Pair;?import android.support.v4.util.Pair;?g' -i $all_java_files
sed -e 's?import androidx.core.os.EnvironmentCompat;?import android.support.v4.os.EnvironmentCompat;?g' -i $all_java_files
sed -e 's?import androidx.core.app.ActivityCompat;?import android.support.v4.app.ActivityCompat;?g' -i $all_java_files
sed -e 's?import androidx.core.content.ContextCompat;?import android.support.v4.content.ContextCompat;?g' -i $all_java_files
sed -e 's?import androidx.core.text.BidiFormatter;?import android.support.v4.text.BidiFormatter;?g' -i $all_java_files
sed -e 's?import androidx.core.text.TextUtilsCompat;?import android.support.v4.text.TextUtilsCompat;?g' -i $all_java_files
sed -e 's?import androidx.annotation.IntRange;?import android.support.annotation.IntRange;?g' -i $all_java_files
sed -e 's?import androidx.annotation.Keep;?import android.support.annotation.Keep;?g' -i $all_java_files
sed -e 's?import androidx.annotation.ColorInt;?import android.support.annotation.ColorInt;?g' -i $all_java_files
sed -e 's?import androidx.appcompat.app.AppCompatActivity;?import android.support.v7.app.AppCompatActivity;?g' -i $all_java_files

sed -e 's?distributionUrl=.*?distributionUrl=https\\://services.gradle.org/distributions/gradle-7.2-bin.zip?g' -i `find -name gradle-wrapper.properties`


all_build_gradle=`find -name build.gradle`
sed -e "s?implementation 'androidx.appcompat:appcompat:[0-9\.\-]*'?implementation 'com.android.support:support-compat:28.0.0'\n    implementation 'com.android.support:appcompat-v7:28.0.0'    \n    implementation 'com.android.support:customview:28.0.0'\n?g" -i $all_build_gradle
sed -e "s?implementation 'androidx.constraintlayout:constraintlayout:2.0.4'?// implementation 'androidx.constraintlayout:constraintlayout:2.0.4'?g" -i $all_build_gradle
sed -e "s?classpath 'com.android.tools.build:gradle:7.0.0'?classpath 'com.android.tools.build:gradle:4.2.0'?g" -i $all_build_gradle

sed -e "s?^    id 'com.android.application' version?//     id 'com.android.application' version?g" -i $all_build_gradle
sed -e "s?^    id 'com.android.library' version?//     id 'com.android.library' version?g" -i $all_build_gradle
sed -e 's?compileSdkVersion [\ 0-9]*?compileSdkVersion 28?g' -i $all_build_gradle
sed -e 's?targetSdkVersion [\ 0-9]*?targetSdkVersion 28?g' -i $all_build_gradle
sed -e 's?buildToolsVersion \"[\-\ 0-9\.a-zA-Z]*\"?buildToolsVersion \"28.0.3\"?g' -i $all_build_gradle
sed -e "s?^    implementation 'com.google.android.material:material:1.4.0'?//     implementation 'com.google.android.material:material:1.4.0'?g" -i $all_build_gradle

sed -e 's?android.useAndroidX=true?android.useAndroidX=false?g' -i `find -name gradle.properties`

#sed -e 's?import androidx.core.util.Pair;?import android.support.v4.util.Pair;?g' -i $all_java_files
#sed -e 's?import androidx.core.util.Pair;?import android.support.v4.util.Pair;?g' -i $all_java_files
#sed -e 's?import androidx.core.util.Pair;?import android.support.v4.util.Pair;?g' -i $all_java_files
#sed -e 's?import androidx.annotation.RequiresApi;?import android.support.annotation.RequiresApi;?g' -i $all_java_files
