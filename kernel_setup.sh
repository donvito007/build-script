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
# End Config

# Select GCC Compiler: eva-gcc, arter97-gcc, choki-gcc
while getopts a: flag; do
  case "${flag}" in
    a) SELECT_TOOL=${OPTARG} ;;
  esac
done

# clone_tc - clones gcc toolchain to TC_DIR
case "${SELECT_TOOL}" in
  "EVA-GCC") clone_tc() {
	git clone --depth=1 https://github.com/mvaisakh/gcc-arm64 $TC_DIR/arm64
	git clone --depth=1 https://github.com/mvaisakh/gcc-arm $TC_DIR/arm
} ;;
  "Choki-GCC") clone_tc() {
	git clone --depth=1 https://github.com/Diaz1401/arm64 $TC_DIR/arm64
	git clone --depth=1 https://github.com/Diaz1401/arm $TC_DIR/arm
} ;;
esac

# Clones anykernel
clone_ak() {
	git clone $AK_REPO $AK_DIR
}

# Actually do stuff#
clone_tc
clone_ak
