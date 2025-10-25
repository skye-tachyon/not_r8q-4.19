#!/bin/bash
LLVM_PATH="$HOME/toolchains/neutron-clang/bin/"
LLVM_PATH="$HOME/toolchains/neutron-clang/bin/"

KERNEL_NAME="Eclipse"

HOST_BUILD_ENV="ARCH=arm64 \
                CC=${LLVM_PATH}clang \
                CROSS_COMPILE=${LLVM_PATH}aarch64-linux-gnu- \
                LLVM=1 \
                LLVM_IAS=1 \
                PATH=$LLVM_PATH:$LLVM_PATH:$PATH"

KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

IMAGE="$HOME/bomb/out/arch/arm64/boot/Image"
OUT_DIR="$HOME/bomb/out"
ANYKERNEL_DIR="$HOME/bomb/AnyKernel3/r8q"

echo "*****************************************"
echo "*****************************************"

rm -rf "$OUT_DIR/arch/arm64/boot/Image"
rm -rf "$ANYKERNEL_DIR/dtb"
rm -rf $HOME/bomb/out/arch/arm64/boot/dtbo.img
rm -rf .version .local
make O="$OUT_DIR" $HOST_BUILD_ENV vendor/kona-not_defconfig vendor/samsung/kona-sec-not.config vendor/samsung/r8q.config vendor/kali.config vendor/lindroid.config

echo "*****************************************"
echo "*****************************************"

# Build Device Tree Blob//Overlay

make -j12 O="$OUT_DIR" $KERNEL_MAKE_ENV $HOST_BUILD_ENV \
     CC="${LLVM_PATH}clang --target=aarch64-linux-gnu" dtbo.img

cp $HOME/bomb/out/arch/arm64/boot/dtbo.img "$ANYKERNEL_DIR/dtbo.img"
cat $HOME/bomb/out/arch/arm64/boot/dts/vendor/qcom/*.dtb > "$ANYKERNEL_DIR/dtb"

# Build Kernel Image

make -j12 O="$OUT_DIR" $KERNEL_MAKE_ENV $HOST_BUILD_ENV \
     CC="${LLVM_PATH}clang --target=aarch64-linux-gnu" Image

echo "**Build outputs**"
ls "$OUT_DIR/arch/arm64/boot"
echo "**Build outputs**"

cp "$IMAGE" "$ANYKERNEL_DIR/Image"

# Package Kernel

gitsha=$(git rev-parse --short HEAD)

cd "$ANYKERNEL_DIR" || exit 1
rm -f *.zip

zip -r9 "not_kernel-${KERNEL_NAME}-$gitsha-$(date +"%Y%m%d")+r8q.zip" .

echo "The bomb has been planted."
