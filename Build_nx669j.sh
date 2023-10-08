#!/bin/bash

DIR=`readlink -f .`
OUT_DIR=$DIR/out
PARENT_DIR=`readlink -f ${DIR}/..`

export CROSS_COMPILE=$PARENT_DIR/clang-r416183b/bin/aarch64-linux-gnu-
export CC=$PARENT_DIR/clang-r416183b/bin/clang

export PLATFORM_VERSION=12
export ANDROID_MAJOR_VERSION=s
export PATH=$PARENT_DIR/clang-r416183b/bin:$PATH
export PATH=$PARENT_DIR/build-tools/path/linux-x86:$PATH
export PATH=$PARENT_DIR/gas/linux-x86:$PATH
export TARGET_SOC=lahaina
export LLVM=1 LLVM_IAS=1
export ARCH=arm64
KERNEL_MAKE_ENV="LOCALVERSION=-Doc714"

clang()
{
  if [ ! -d $PARENT_DIR/clang-r416183b ]; then
    git clone https://github.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-r416183b $PARENT_DIR/clang-r416183b
  fi
}

gas()
{
  if [ ! -d $PARENT_DIR/gas/linux-x86 ]; then
    git clone https://android.googlesource.com/platform/prebuilts/gas/linux-x86 $PARENT_DIR/gas/linux-x86
  fi
}

build_tools()
{
  if [ ! -d $PARENT_DIR/build-tools ]; then
    git clone https://android.googlesource.com/platform/prebuilts/build-tools $PARENT_DIR/build-tools
  fi
}

clean()
{
  make clean
  make mrproper
  [ -d "$OUT_DIR" ] && rm -rf $OUT_DIR
}

build_kernel()
{
  [ ! -d "$OUT_DIR" ] && mkdir $OUT_DIR
  make -j$(nproc) -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV vendor/nx669j_defconfig
  make -j$(nproc) -C $(pwd) O=$(pwd)/out $KERNEL_MAKE_ENV

  [ -e $OUT_DIR/arch/arm64/boot/Image.gz ] && cp $OUT_DIR/arch/arm64/boot/Image.gz $OUT_DIR/Image.gz
  if [ -e $OUT_DIR/arch/arm64/boot/Image ]; then
    cp $OUT_DIR/arch/arm64/boot/Image $OUT_DIR/Image
  fi
}

anykernel3()
{
  if [ ! -d $PARENT_DIR/AnyKernel3 ]; then
    git clone https://github.com/osm0sis/AnyKernel3 $PARENT_DIR/AnyKernel3
  fi
  if [ -e $OUT_DIR/arch/arm64/boot/Image ]; then
    cd $PARENT_DIR/AnyKernel3
    git reset --hard
    cp $OUT_DIR/arch/arm64/boot/Image zImage
    sed -i "s/ExampleKernel by osm0sis/NX669J kernel by Doc714/g" anykernel.sh
    sed -i "s/do\.devicecheck=1/do\.devicecheck=0/g" anykernel.sh
    sed -i "s/=maguro/=/g" anykernel.sh
    sed -i "s/=toroplus/=/g" anykernel.sh
    sed -i "s/=toro/=/g" anykernel.sh
    sed -i "s/=tuna/=/g" anykernel.sh
    sed -i "s/platform\/omap\/omap_hsmmc\.0\/by-name\/boot/bootdevice\/by-name\/boot/g" anykernel.sh
    sed -i "s/backup_file/#backup_file/g" anykernel.sh
    sed -i "s/replace_string/#replace_string/g" anykernel.sh
    sed -i "s/insert_line/#insert_line/g" anykernel.sh
    sed -i "s/append_file/#append_file/g" anykernel.sh
    sed -i "s/patch_fstab/#patch_fstab/g" anykernel.sh
    sed -i "s/dump_boot/split_boot/g" anykernel.sh
    sed -i "s/write_boot/flash_boot/g" anykernel.sh
    zip -r9 $PARENT_DIR/nx669j_kernel_`cat $OUT_DIR/include/config/kernel.release`_`date '+%Y_%m_%d'`.zip * -x .git README.md *placeholder
  fi
}


clang
gas
build_tools
clean
build_kernel
anykernel3
