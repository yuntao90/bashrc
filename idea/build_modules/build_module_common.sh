#!/bin/bash

function check_env_dir_exists() {
  errFound=0
  while [[ $# -gt 0 ]] ; do
    v="$1"
    if [[ ! -d "${!v}" ]] ; then
      errFound=1
      echo "Directory $v(=${!v}) not exists!"
    fi
    shift
  done
  return $errFound
}

function check_variable_declared() {
  errFound=0
  while [[ $# -gt 0 ]] ; do
    v="$1"
    if [[ -z "${!v}" ]] ; then
      errFound=1
      echo "Variable $v not declared!"
    fi
    shift
  done
  return $errFound
}


target_platform=""

if [[ -z "$out" ]] ; then
  guess_out=""
  if [[ -n "${BASH_SOURCE[1]}" ]] ; then
    SCRIPT_NAME="${BASH_SOURCE[1]}"
  fi
  if [[ -z "$SCRIPT_NAME" ]] ; then
    SCRIPT_NAME="${BASH_SOURCE[0]}"
  fi

  if [[ -n "$SCRIPT_NAME" ]] ; then
    guess_out="$(basename "$SCRIPT_NAME")"
    guess_out="${guess_out%*.sh}"
    guess_out="${guess_out##*_}"
  fi

  if [[ -n "$guess_out" ]] ; then
    out="build_$guess_out"
  else # guess_out is empty
    out="build_android"
  fi

fi # out is empty

target_platform=$guess_out

case $target_platform in
android*)
  echo "Found platform: Android"
  if ! check_env_dir_exists ANDROID_NDK ; then
    echo "Some pre-conditions check failure. exit will be called after 3s, [Ctrl+C] to abort exiting."
    sleep 3
    exit 1
  fi

  ANDROID=1

  ANDROID_ARCH_arm="arm"
  ANDROID_ARCH2_arm="armv7a"
  ANDROID_ABI_arm="armeabi-v7a"
  ANDROID_ABI_NEON_arm="armeabi-v7a with NEON"
  ANDROID_API_LEVEL=21
  EABI_arm=eabi
  CMAKE_ANDROID_ARCH_arm="armv7-a"

  NDK_SYSROOT=$ANDROID_NDK/sysroot/usr
  PLATFORM_SYSROOT_arm=$ANDROID_NDK/platforms/android-$ANDROID_API_LEVEL/arch-$ANDROID_ARCH_arm/usr
  CROSS_COMPILE_arm=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/${ANDROID_ARCH_arm}-linux-android${EABI_arm}-
  CC_arm=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/${ANDROID_ARCH2_arm}-linux-android${EABI_arm}${ANDROID_API_LEVEL}-clang
  CXX_arm=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/${ANDROID_ARCH2_arm}-linux-android${EABI_arm}${ANDROID_API_LEVEL}-clang++
  LD_arm=${CROSS_COMPILE}ld

  module_generic_androidarm_options=( \
    -DCMAKE_HOST_SYSTEM_NAME=Linux \
    -DCMAKE_HOST_SYSTEM_PROCESSOR=x86_64 \
    -DCMAKE_SYSTEM_NAME=Android \
    -DCMAKE_SYSTEM_PROCESSOR="armv7-a" \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
    -DANDROID_TOOLCHAIN_NAME="${ANDROID_ARCH2_arm}-linux-android${EABI_arm}-" \
    -DANDROID_NATIVE_API_LEVEL=android-${ANDROID_API_LEVEL} \
    -DANDROID_ABI="$ANDROID_ABI_NEON_arm" \
    -DANDROID_STL=c++_static \
    -DANDROID_TOOLCHAIN='clang' \
    -DCMAKE_CROSSCOMPILING=ON \
    -DCMAKE_FIND_ROOT_PATH="$NDK_SYSROOT" \
    -DCMAKE_FIND_ROOT_PATH="$PLATFORM_SYSROOT_arm" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
  )

  module_generic_androidarm_armmode_options=( \
    -DANDROID_FORCE_ARM_BUILD=ON \
  )


  ANDROID_ARCH_arm64="arm64"
  ANDROID_ARCH2_arm64="aarch64"
  ANDROID_ABI_arm64="arm64-v8a"
  ANDROID_API_LEVEL=21
  EABI_arm64=""
  CMAKE_ANDROID_ARCH_arm64="aarch64"

  NDK_SYSROOT=$ANDROID_NDK/sysroot/usr
  PLATFORM_SYSROOT_arm64=$ANDROID_NDK/platforms/android-$ANDROID_API_LEVEL/arch-$ANDROID_ARCH_arm64/usr

  CROSS_COMPILE_arm64=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/${ANDROID_ARCH2_arm64}-linux-android${EABI_arm64}-
  CC_arm64=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/${ANDROID_ARCH2_arm64}-linux-android${EABI_arm64}${ANDROID_API_LEVEL}-clang
  CXX_arm64=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/${ANDROID_ARCH2_arm64}-linux-android${EABI_arm64}${ANDROID_API_LEVEL}-clang++
  LD_arm64=${CROSS_COMPILE_arm64}ld

  module_generic_androidarm64_options=( \
    -DCMAKE_HOST_SYSTEM_NAME=Linux \
    -DCMAKE_HOST_SYSTEM_PROCESSOR=x86_64 \
    -DCMAKE_SYSTEM_NAME=Android \
    -DCMAKE_SYSTEM_PROCESSOR="$CMAKE_ANDROID_ARCH_arm64" \
    -DANDROID_TOOLCHAIN_NAME="${ANDROID_ARCH2_arm64}-linux-android${EABI_arm64}-" \
    -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
    -DANDROID_NATIVE_API_LEVEL=android-${ANDROID_API_LEVEL} \
    -DCMAKE_CROSSCOMPILING=ON \
    -DANDROID_STL=c++_static \
    -DCMAKE_FIND_ROOT_PATH="$NDK_SYSROOT" \
    -DCMAKE_FIND_ROOT_PATH="$PLATFORM_SYSROOT_arm64" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
  )

  ;;
*)
  ANDROID=0
  if [[ -z "$GCC_TOOLCHAIN_ROOT" ]] ; then
    preset_toolchain_name=GCC_TOOLCHAIN_ROOT_${target_platform}
    export GCC_TOOLCHAIN_ROOT="${!preset_toolchain_name}"
  fi

  echo "DEBUG: GCC_TOOLCHAIN_ROOT=$GCC_TOOLCHAIN_ROOT, CROSS_COMPILE=$CROSS_COMPILE"
  if [ -z "$GCC_TOOLCHAIN_ROOT" -a -n "$CROSS_COMPILE" ] ; then
    export GCC_TOOLCHAIN_ROOT="$(dirname "$(dirname "$CROSS_COMPILE")")"
    echo "Try parse GCC_TOOLCHAIN_ROOT from CROSS_COMPILE($CROSS_COMPILE)"
    export GCC_MACHINE="$(echo -n "$(basename "$CROSS_COMPILE")" | sed -e 's?\-$??g')"
  fi

  if ! check_env_dir_exists GCC_TOOLCHAIN_ROOT || ! check_variable_declared GCC_MACHINE ; then
    echo "Some pre-conditions check failure. Abort!"
    exit 1
  fi
  export CROSS_COMPILE=${GCC_TOOLCHAIN_ROOT}/bin/${GCC_MACHINE}-
  export GCC_TOOLCHAIN_SYSROOT=${GCC_TOOLCHAIN_ROOT}/${GCC_MACHINE}/sysroot
  CXX="$CROSS_COMPILE"g++
  CC="$CROSS_COMPILE"gcc
  AR="$CROSS_COMPILE"ar

  module_generic_embedded_options=( \
      -DCMAKE_HOST_SYSTEM_NAME=Linux \
      -DCMAKE_HOST_SYSTEM_PROCESSOR=$(uname -m) \
      -DCMAKE_SYSTEM_NAME=Linux \
      -DCMAKE_SYSTEM_PROCESSOR=$TARGET_ARCH \
      -DCMAKE_CROSSCOMPILING=ON \
      -DCMAKE_C_COMPILER="$CC" \
      -DCMAKE_CXX_COMPILER="$CXX" \
      -DCMAKE_FIND_ROOT_PATH="$GCC_TOOLCHAIN_SYSROOT" \
      -DCMAKE_FIND_ROOT_PATH="$TARGET_SYSROOT" \
      -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
      -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
  )

  ;;
esac

CMAKE="`which cmake3`"
if [[ -z "$CMAKE" ]] ; then
  CMAKE="cmake"
fi

NPROC="$(nproc)"
if [[ -z "$NPROC" ]] ; then
  NPROC=4
fi

########################
# Generic module options
########################

module_opencv_embedded_options=( \
  -DBUILD_LIST='optflow,flann,gapi,core,dnn,features2d,flann,imgcodecs,imgproc,ml,objdetect,ximgproc,tracking,video,videoio,plot,stitching,tracking,photo,highgui' \
  -DOPENCV_EXTRA_MODULES_PATH='../../opencv_contrib/modules' \
  -DBUILD_TESTS=OFF \
  -DINSTALL_TESTS=OFF \
  -DBUILD_EXAMPLES=OFF \
  -DBUILD_ANDROID_EXAMPLES=OFF \
  -DINSTALL_ANDROID_EXAMPLES=OFF \
  -DINSTALL_PYTHON_EXAMPLES=OFF \
  -DINSTALL_C_EXAMPLES=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DINSTALL_CREATE_DISTRIB=ON \
  -DWITH_TBB=ON \
  -DWITH_OPENCL=ON \
  -DWITH_IPP=OFF \
  -DBUILD_DOCS=OFF \
  -DENABLE_NEON=ON \
)

module_mnn_embedded_options=( \
  -DMNN_BUILD_BENCHMARK=OFF \
  -DMNN_BUILD_HARD=ON \
  -DMNN_BUILD_TEST=OFF \
  -DMNN_BUILD_SHARED_LIBS=OFF \
  -DMNN_USE_SSE=OFF \
  -DMNN_USE_THREAD_POOL=ON \
  -DMNN_SEP_BUILD=OFF \
  -DMNN_OPENMP=OFF \
  -DMNN_OPENGL=OFF \
  -DMNN_PORTABLE_BUILD=ON \
)


module_mnn_android_options=(\
  -DMNN_BUILD_FOR_ANDROID_COMMAND=ON \
  -DMNN_USE_LOGCAT=ON \
)

module_mnn_bf16_options=( \
    -DMNN_SUPPORT_BF16=OFF \
)

module_protobuf_embedded_options=( \
  -Dprotobuf_BUILD_TESTS=OFF \
  -Dprotobuf_BUILD_PROTOC_BINARIES=OFF \
  -DBUILD_SHARED_LIBS=OFF \
  -Dprotobuf_BUILD_SHARED_LIBS=OFF \
)
