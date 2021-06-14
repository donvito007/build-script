#!/bin/bash
#
# Copyright (c) 2021 CloudedQuartz
#

# Script to set up environment to build an android kernel
# Assumes required packages are already installed

# Config
CUR_DIR="$(pwd)"
KERNELNAME="Kucing"
AK_REPO="https://github.com/Diaz1401/AnyKernel3"
AK_DIR="$HOME/AnyKernel3"
TC_DIR="$HOME"
# End Config

# Select GCC Compiler (-a) : eva-gcc, arter97-gcc, choki-gcc or Select build with LTO or not (-b) : y, n
while getopts "a:b:" flag; do
  case "${flag}" in
    a) SELECT_TOOL=${OPTARG} ;;
    b) SELECT_LTO=${OPTARG} ;;
  esac
done

# clone_tc - clones gcc toolchain to TC_DIR
case "${SELECT_TOOL}" in
  "eva-gcc") clone_tc() {
    echo "EVA-GCC" > SELECT_TOOL
	git clone --depth=1 https://github.com/mvaisakh/gcc-arm64 $TC_DIR/arm64
	git clone --depth=1 https://github.com/mvaisakh/gcc-arm $TC_DIR/arm
} ;;
  "arter97-gcc") clone_tc() {
    echo "Arter97-GCC" > SELECT_TOOL
	git clone --depth=1 https://github.com/arter97/arm64-gcc $TC_DIR/arm64
	git clone --depth=1 https://github.com/arter97/arm32-gcc $TC_DIR/arm
} ;;
  "choki-gcc") clone_tc() {
    echo "Choki-GCC" > SELECT_TOOL
	git clone --depth=1 https://github.com/Diaz1401/arm64 $TC_DIR/arm64
	git clone --depth=1 https://github.com/Diaz1401/arm $TC_DIR/arm
} ;;
esac

case "${SELECT_LTO}" in
  "y") kernel_build() {
    echo "LTO" > SELECT_LTO
	bash kernel_build.sh -a y
} ;;
  "n") kernel_build() {
    echo "NON-LTO" > SELECT_LTO
	bash kernel_build.sh -a n
} ;;
esac

# Set timezone
set_time() {
    sudo timedatectl set-timezone Asia/Jakarta
}

# Clones anykernel
clone_ak() {
	git clone $AK_REPO $AK_DIR
}

# Actually do stuff
set_time
clone_tc
clone_ak

# Run build script
kernel_build
