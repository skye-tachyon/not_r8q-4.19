SECONDS=0 # builtin bash timer

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'


ZIPNAME="not-$(date '+%Y%m%d-%H%M')-r8q.zip"
TC_DIR="$(pwd)/tc/clang-r522817"
AK3_DIR="$(pwd)/AnyKernel3"
DEFCONFIG="vendor/kona-not_defconfig vendor/samsung/kona-sec-not.config vendor/samsung/r8q.config vendor/not/no_werror.config vendor/not/no_lto.config"

OUT_DIR="$(pwd)/out"
BOOT_DIR="$OUT_DIR/arch/arm64/boot"
DTS_DIR="$BOOT_DIR/dts/vendor/qcom"

if test -z "$(git rev-parse --show-cdup 2>/dev/null)" &&
   head=$(git rev-parse --verify HEAD 2>/dev/null); then
    ZIPNAME="${ZIPNAME::-4}-$(echo $head | cut -c1-8).zip"
fi

export PATH="$TC_DIR/bin:$PATH"

if ! [ -d "$TC_DIR" ]; then
    echo -e "${YELLOW}AOSP clang not found! Cloning to $TC_DIR...${NC}"
    if ! git clone --depth=1 -b 18 https://gitlab.com/ThankYouMario/android_prebuilts_clang-standalone "$TC_DIR"; then
        echo -e "${RED}Cloning failed! Aborting...${NC}"
        exit 1
    fi
fi

mkdir -p out
echo -e "${YELLOW}building with: $DEFCONFIG${NC}"
make O=out ARCH=arm64 $DEFCONFIG

echo -e "\n${YELLOW}Starting compilation...${NC}\n"

make -j$(nproc --all) O=out ARCH=arm64 \
    CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm \
    OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip \
    CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    LLVM=1 LLVM_IAS=1 dtbo.img
    
make -j$(nproc --all) O=out ARCH=arm64 \
    CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm \
    OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip \
    CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
    LLVM=1 LLVM_IAS=1 Image
    
if [ -f "$BOOT_DIR/Image" ]; then
    echo -e "${GREEN}Kernel Image found!${NC}"
    
    if [ -d "$DTS_DIR" ]; then
        echo -e "${BLUE}Generating dtb.img from $DTS_DIR...${NC}"
        cat $(find "$DTS_DIR" -type f -name "*.dtb" | sort) > "$BOOT_DIR/kona.dtb"
        
        if [ -f "$BOOT_DIR/kona.dtb" ]; then
            echo -e "${GREEN}dtb.img generated successfully!${NC}"
        else
            echo -e "${RED}Failed to generate kona.dtb! Check if dtbs were compiled.${NC}"
            exit 1
        fi
    else
        echo -e "${RED}DTS directory not found. Compilation might be incomplete.${NC}"
        exit 1
    fi
else
    echo -e "\n${RED}Compilation failed! Image not found.${NC}"
    exit 1
fi

echo -e "Preparing zip...\n"

cp "$BOOT_DIR/dtbo.img" AnyKernel3/dtbo.img
cp "$BOOT_DIR/Image" AnyKernel3/Image
cp "$BOOT_DIR/kona.dtb" AnyKernel3/kona.dtb

cd AnyKernel3

zip -r9 "../$ZIPNAME" * -x .git README.md *placeholder
cd ..

echo -e "\n${GREEN}Completed in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s)!${NC}"
echo -e "${GREEN}Zip: $ZIPNAME${NC}"
