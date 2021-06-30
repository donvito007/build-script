#!/bin/bash
#
# Copyright (c) 2021 CloudedQuartz

CURRENT_DIR="$(pwd)"
KERNELNAME="Kucing"
KERNEL_DIR="$CURRENT_DIR"
AK_REPO="https://github.com/Diaz1401/AnyKernel3"
AK_DIR="$HOME/AnyKernel3"
TC_DIR="$HOME"
LOG="$HOME/log.txt"
KERNEL_IMG=$KERNEL_DIR/out/arch/$ARCH/boot/Image.gz-dtb
TG_CHAT_ID="942627647"
TG_BOT_TOKEN="$(cat $KERNEL_DIR/key.txt)"
GCC_VER="$1" # write from 10 to 12, example: bash build.sh 11

#
# Export arch, subarch, etc
export ARCH="arm64"
export SUBARCH="arm64"

#
# Clone GCC Compiler
clone_tc() {
	git clone --depth=1 https://github.com/Diaz1401/gcc"$GCC_VER"-arm64 $TC_DIR/arm64
	git clone --depth=1 https://github.com/Diaz1401/gcc"$GCC_VER"-arm $TC_DIR/arm
}

#
# Clones anykernel
clone_ak() {
	git clone $AK_REPO $AK_DIR
}

#
# tg_sendinfo - sends text through telegram
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
# build_setup - enter kernel directory
build_setup() {
    cd "$KERNEL_DIR"
    rm -rf out
    mkdir out
}

#
# build_config - builds .config file for device.
build_config() {
	make O=out beryllium_defconfig -j4
}

#
# build_kernel
build_kernel() {

    BUILD_START=$(date +"%s")
    make -j4 O=out \
                PATH="$TC_DIR/arm64/bin:$TC_DIR/arm/bin:$PATH" \
                CROSS_COMPILE=$TC_DIR/arm64/bin/aarch64-elf- \
                CROSS_COMPILE_ARM32=$TC_DIR/arm/bin/arm-eabi- |& tee $LOG

    BUILD_END=$(date +"%s")
    DIFF=$((BUILD_END - BUILD_START))
    BUILD_DATE=$(date +"%A"_"%I":"%M"_"%p")
}

#
# build_end - creates and sends zip
build_end() {

	if ! [ -a "$KERNEL_IMG" ]; then
        echo -e "\n> Build failed, sed"
        tg_log
        exit 1
    fi

    echo -e "\n> Build successful! generating flashable zip..."
	cd "$AK_DIR" || echo -e "\nAnykernel directory ($AK_DIR) does not exist" || exit 1
	git clean -fd
	mv "$KERNEL_IMG" "$AK_DIR"/zImage
	ZIP_NAME=$KERNELNAME-$BUILD_DATE
	zip -r9 "$ZIP_NAME".zip ./* -x .git README.md ./*placeholder
        ZIP_NAME="$ZIP_NAME".zip

	echo -e "\n> Sent zip and log through Telegram."
	tg_pushzip "$ZIP_NAME" "Time taken: <code>$((DIFF / 60))m $((DIFF % 60))s</code>"
	sleep 10
	tg_log
}

#
# build time
clone_tc
clone_ak
tg_sendinfo "Build Started at $(date +"%A"_"%I":"%M"_"%p")
"
build_setup
build_config
build_kernel
build_end
