#!/bin/bash

KERNEL_DIR=$PWD

if [ -z ../sc02c_initramfs ]; then
  echo 'error: sc02c_initramfs directory not found'
  exit -1
fi

cd ../sc02c_initramfs
if [ ! -n "`git status | grep clean`" ]; then
  echo 'error: sc02c_initramfs is not clean'
  exit -1
fi
git checkout ics
cd $KERNEL_DIR

read -p "select build type? [(r)elease/(n)ightly] " BUILD_TYPE
if [ "$BUILD_TYPE" != 'release' -a "$BUILD_TYPE" != 'r' ]; then
  export NIGHTLY_BUILD=y
else
  unset NIGHTLY_BUILD
fi

# create release dir＿
RELEASE_DIR=../release/`date +%Y%m%d`
mkdir -p $RELEASE_DIR

# build for samsung
bash ./build-samsung.sh a
if [ $? != 0 ]; then
  echo 'error: samsung build fail'
  exit -1
fi
mv -v ./out/* $RELEASE_DIR

# build for aosp
bash ./build-aosp.sh a
if [ $? != 0 ]; then
  echo 'error: aosp build fail'
  exit -1
fi
mv -v ./out/* $RELEASE_DIR

# build for multiboot
cd ../sc02c-initramfs
git checkout ics-multiboot
cd $KERNEL_DIR
bash ./build-multi.sh a
if [ $? != 0 ]; then
  echo 'error: multi build fail'
  exit -1
fi
mv -v ./out/* $RELEASE_DIR