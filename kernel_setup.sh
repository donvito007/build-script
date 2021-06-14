#!/bin/bash
#
# Copyright (c) 2021 CloudedQuartz
#

# Script to set up environment to build an android kernel
# Assumes required packages are already installed

# Config
CURRENT_DIR="$(pwd)"
KERNELNAME="Choki"
KERNEL_DIR="$CURRENT_DIR"
AK_REPO="https://github.com/Diaz1401/AnyKernel3"
AK_DIR="$HOME/AnyKernel3"
TC_DIR="$HOME"

# Select GCC Compiler: eva-gcc, arter97-gcc
while getopts a: flag; do
  case "${flag}" in
    a) TOOLCHAIN=${OPTARG} ;;
  esac
done

case "${TOOLCHAIN}" in
  "eva-gcc") clone_tc="clone_tc1" ;;
  "arter97-gcc") clone_tc="clone_tc2" ;;
esac
# End Config

# clone_tc - clones gcc toolchain to TC_DIR
clone_tc1() {
	git clone --depth=1 https://github.com/mvaisakh/gcc-arm64 $TC_DIR/arm64
	git clone --depth=1 https://github.com/mvaisakh/gcc-arm $TC_DIR/arm
}

clone_tc2() {
	git clone --depth=1 https://github.com/arter97/arm64-gcc $TC_DIR/arm64
	git clone --depth=1 https://github.com/arter97/arm32-gcc $TC_DIR/arm
}

# Clones anykernel
clone_ak() {
	git clone $AK_REPO $AK_DIR
}
# Actually do #
clone_tc
clone_ak

# Run build script
. ${CURRENT_DIR}/kernel_build.sh
