#!/bin/bash
LLVM_PATH="/home/skye/toolchains/zyc-clang/bin/"

HOST_BUILD_ENV="ARCH=arm64 \
                CC=${LLVM_PATH}clang \
                CROSS_COMPILE=${LLVM_PATH}aarch64-linux-gnu- \
                LLVM=1 \
                LLVM_IAS=1 \
                PATH=$LLVM_PATH:$PATH \
                -j$(nproc --all)"

KERNEL_MAKE_ENV="DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y"

DTBO_OUT="/home/skye/bomb/out/arch/arm64/boot"
DTB_OUT="/home/skye/bomb/out/arch/arm64/boot/dts/vendor/qcom"
IMAGE="/home/skye/bomb/out/arch/arm64/boot/Image"
OUT_DIR="/home/skye/bomb/out"
ANYKERNEL_DIR="/home/skye/bomb/AnyKernel3/r8q"

echo "*****************************************"
echo "*****************************************"

rm -rf "$OUT_DIR/arch/arm64/boot/Image"
rm -rf "$ANYKERNEL_DIR/kona.dtb"
rm -rf "$OUT_DIR/dtbo.img"
rm -rf .version .local
make O="$OUT_DIR" $HOST_BUILD_ENV vendor/kona-not_defconfig vendor/samsung/kona-sec-not.config vendor/samsung/r8q.config vendor/not/no_lto.config

echo "*****************************************"
echo "*****************************************"

# Build Device Tree Blob//Overlay

make -j12 O="$OUT_DIR" $KERNEL_MAKE_ENV $HOST_BUILD_ENV dtbo.img

cp "$DTBO_OUT/dtbo.img" "$ANYKERNEL_DIR/dtbo.img"
cat "$DTB_OUT"/*.dtb > "$ANYKERNEL_DIR/kona.dtb"

# Build Kernel Image

make -j12 O="$OUT_DIR" $KERNEL_MAKE_ENV $HOST_BUILD_ENV Image

echo "**Build outputs**"
ls "$OUT_DIR/arch/arm64/boot"
echo "**Build outputs**"

cp "$IMAGE" "$ANYKERNEL_DIR/Image"

# Package Kernel

gitsha=$(git rev-parse --short HEAD)

cd "$ANYKERNEL_DIR" || exit 1
rm -f *.zip

zip -r9 "not-$gitsha+r8q.zip" .

echo "The bomb has been planted."
