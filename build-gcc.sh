#!/bin/bash

# Copyright (c) 2021 CloudedQuartz
# Copyright (c) 2021 Diaz1401

KERNEL_NAME="Kucing"
KERNEL_DIR="$(pwd)"
AK3="$KERNEL_DIR/AnyKernel3"
TOOLCHAIN="$KERNEL_DIR/gcc"
LOG="$KERNEL_DIR/log.txt"
KERNEL_IMG="$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb"
KERNEL_DTBO="$KERNEL_DIR/out/arch/arm64/boot/dtbo.img"
TG_CHAT_ID="-1001180467256"
TG_BOT_TOKEN="$TELEGRAM_TOKEN"
GCC_VER="$1" # write from 10 to 12, example: bash build-gcc.sh 11

export KBUILD_BUILD_USER="Diaz"
export KBUILD_BUILD_HOST="DroneCI"
export PATH="$TOOLCHAIN/arm64/bin:$TOOLCHAIN/arm/bin:$PATH"

MAKE="./makeparallel"

#
# Clone Clang Compiler
clone_tc() {
        git clone https://github.com/Diaz1401/gcc-arm64 --depth 1 -b gcc-$GCC_VER $TOOLCHAIN/arm64
	git clone https://github.com/Diaz1401/gcc-arm --depth 1 -b gcc-$GCC_VER $TOOLCHAIN/arm
}

#
# Clones anykernel
clone_ak() {
        git clone --depth 1 https://github.com/Diaz1401/AnyKernel3.git -b alioth $AK3
}

#
# tg_sendinfo - sends text to telegram
tg_sendinfo() {
        curl -s "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" \
                -F parse_mode=html \
                -F text="${1}" \
                -F chat_id="${TG_CHAT_ID}" &> /dev/null
}

#
# tg_pushzip - uploads final zip to telegram
tg_pushzip() {
        curl -F document=@"$1"  "https://api.telegram.org/bot$TG_BOT_TOKEN/sendDocument" \
                        -F chat_id=$TG_CHAT_ID \
                        -F caption="$2" \
                        -F parse_mode=html &> /dev/null
}

#
# tg_log - uploads build log to telegram
tg_log() {
    curl -F document=@"$LOG"  "https://api.telegram.org/bot$TG_BOT_TOKEN/sendDocument" \
        -F chat_id=$TG_CHAT_ID \
        -F parse_mode=html &> /dev/null
}

#
# build_kernel
build_kernel() {
    cd "$KERNEL_DIR"
    rm -rf out
    mkdir out
    BUILD_START=$(date +"%s")
    make O=out cat_defconfig
    make -j$(nproc --all) O=out \
        CROSS_COMPILE=aarch64-elf- \
        CROSS_COMPILE_ARM32=arm-eabi- |& tee $LOG

    BUILD_END=$(date +"%s")
    DIFF=$((BUILD_END - BUILD_START))
    DATE_NAME=$(date +"%A"_"%I":"%M"_"%p")
}

#
# build_end - creates and sends zip
build_end() {

    if ! [[ -a "$KERNEL_IMG" && -a "$KERNEL_DTBO" ]]; then
    echo -e "Build failed, sad"
    tg_log
    exit 1
    fi

    echo -e "Build success, generating flashable zip..."
    cd $AK3
    mv "$KERNEL_IMG" "$AK3"
    mv "$KERNEL_DTBO" "$AK3"
    ZIP_NAME=$KERNEL_NAME-$DATE_NAME
    zip -r9 "$ZIP_NAME".zip * -x .git README
    ZIP_NAME="$ZIP_NAME".zip

    echo -e "Send zip to Telegram"
    tg_pushzip "$ZIP_NAME" "Time taken: <code>$((DIFF / 60))m $((DIFF % 60))s</code>"
    tg_log
}

COMMIT=$(git log --pretty=format:"%s" -1)
COMMIT_SHA=$(git rev-parse --short HEAD)
KERNEL_BRANCH=$(git rev-parse --abbrev-ref HEAD)
BUILD_DATE=$(date)
CAPTION=$(echo -e \
"Build started
Date: <code>$BUILD_DATE</code>
HEAD: <code>$COMMIT_SHA</code>
Commit: <code>$COMMIT</code>
Branch: <code>$KERNEL_BRANCH</code>
")

#
# compile time
clone_tc
clone_ak
tg_sendinfo "$CAPTION
"
build_kernel
build_end
