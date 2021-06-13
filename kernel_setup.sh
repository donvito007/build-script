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
BRANCH_ARM64="63184f4c4963fe303abd9cae6c05df5222cb8229"
BRANCH_ARM="c74ca949048d1421522afc24748dbda9b70ec924"
# End Config

# clone_tc - clones proton clang to TC_DIR
clone_tc() {
	wget https://github.com/mvaisakh/gcc-arm64/archive/$BRANCH_ARM64.zip && unzip $BRANCH_ARM64.zip && mv -f gcc-arm64-$BRANCH_ARM64 $TC_DIR/arm64
	wget https://github.com/mvaisakh/gcc-arm/archive/$BRANCH_ARM.zip && unzip $BRANCH_ARM.zip && mv -f gcc-arm-$BRANCH_ARM $TC_DIR/arm
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
