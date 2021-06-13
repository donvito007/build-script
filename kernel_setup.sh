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

# clone_tc - clones proton clang to TC_DIR
clone_tc() {
	git clone --depth=1 https://github.com/mvaisakh/gcc-arm64 $TC_DIR/arm64
	git clone --depth=1 https://github.com/mvaisakh/gcc-arm $TC_DIR/arm
        git clone --depth=1 https://github.com/kdrag0n/proton-clang $TC_DIR/clang
        cd $TC_DIR/clang
        sudo cp -rf bin /usr/
}
# Clones anykernel
clone_ak() {
	git clone $AK_REPO $AK_DIR
}
# Actually do stuff
clone_tc
clone_ak

# Run build script
. ${CURRENT_DIR}/kernel_build.sh
