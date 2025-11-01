#!/bin/bash

# --- Helper for logging ---
info() {
    echo -e "\n\e[1;36m==>\e[0m \e[1m$1\e[0m"
}

# --- Dependency Check ---
info "Checking for build dependencies"
DEPS=("curl" "jq" "tar" "zstd")
missing_deps=0
for dep in "${DEPS[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        echo -e "\e[1;31mError: Required command '$dep' is not installed.\e[0m"
        missing_deps=1
    fi
done

if [ "$missing_deps" -eq 1 ]; then
    echo -e "\e[1;31mPlease install the missing dependencies and try again.\e[0m"
    exit 1
fi

# --- Toolchain Installation ---
info "Setting up toolchain"

# 1. Define toolchain paths
TOOLCHAIN_PARENT_DIR="$HOME/toolchains"
LLVM_DIR="$TOOLCHAIN_PARENT_DIR/neutron-clang"
API_URL="https://api.github.com/repos/Neutron-Toolchains/clang-build-catalogue/releases/latest"
TEMP_ARCHIVE_PATH="$TOOLCHAIN_PARENT_DIR/neutron-clang.tar.zst"

# 2. Check if toolchain already exists
if [ -d "$LLVM_DIR/bin" ]; then
    info "Neutron Clang toolchain already found at $LLVM_DIR"
else
    info "Neutron Clang not found. Downloading latest release..."
    
    # 3. Find the download URL
    DOWNLOAD_URL=$(curl -sL "$API_URL" | \
                   jq -r '.assets[] | select(.name | startswith("neutron-clang-") and endswith(".tar.zst")) | .browser_download_url')

    if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" == "null" ]; then
        echo -e "\e[1;31mError: Could not find a matching 'neutron-clang-*.tar.zst' asset in the latest release.\e[0m"
        exit 1
    fi

    # 4. Download and extract
    echo "Downloading from: $DOWNLOAD_URL"
    # Create the target directory first
    mkdir -p "$LLVM_DIR"
    
    if ! curl -L "$DOWNLOAD_URL" -o "$TEMP_ARCHIVE_PATH"; then
        echo -e "\e[1;31mError: Download failed.\e[0m"
        rm -f "$TEMP_ARCHIVE_PATH"
        exit 1
    fi
    
    info "Extracting toolchain..."
    # **FIX:** Extract *into* $LLVM_DIR and strip the top-level directory 
    # from the archive (e.g., 'neutron-clang-17.0.0.../').
    if ! tar -I 'zstd' -xvf "$TEMP_ARCHIVE_PATH" -C "$LLVM_DIR" --strip-components=1; then
        echo -e "\e[1;31mError: Extraction failed. The archive might be corrupt or have an unexpected structure.\e[0m"
        rm -f "$TEMP_ARCHIVE_PATH"
        rm -rf "$LLVM_DIR" # Clean up failed extraction
        exit 1
    fi
    
    # 5. Clean up
    rm -f "$TEMP_ARCHIVE_PATH"
    info "Toolchain installed successfully to $LLVM_DIR"
fi
# --- End Toolchain Installation ---


# --- START OF YOUR INITIAL SCRIPT ---

# This line now points to the directory managed by the script above
LLVM_PATH="$LLVM_DIR/bin/"
# (Removed your duplicate LLVM_PATH line)

KERNEL_NAME="Eclipse"

# **FIX:** Removed the invisible non-breaking spaces before each line.
# Also removed the redundant '$LLVM_PATH' from the PATH variable.
HOST_BUILD_ENV="ARCH=arm64 \
                CC=${LLVM_PATH}clang \
                CROSS_COMPILE=${LLVM_PATH}aarch64-linux-gnu- \
                LLVM=1 \
                LLVM_IAS=1 \
                PATH=$LLVM_PATH:$PATH"

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

# **FIX:** Removed the invisible non-breaking spaces before the 'CC=' line
make -j$(nproc) O="$OUT_DIR" $KERNEL_MAKE_ENV $HOST_BUILD_ENV \
    CC="${LLVM_PATH}clang --target=aarch64-linux-gnu" dtbo.img

cp $HOME/bomb/out/arch/arm64/boot/dtbo.img "$ANYKERNEL_DIR/dtbo.img"
cat $HOME/bomb/out/arch/arm64/boot/dts/vendor/qcom/*.dtb > "$ANYKERNEL_DIR/dtb"

# Build Kernel Image

# **FIX:** Removed the invisible non-breaking spaces before the 'CC=' line
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
