#!/bin/bash

# Warna teks
GREEN='\033[0;32m'
NC='\033[0m'

# add kernelsu
if [ ! -d "$(pwd)/KernelSU-Next" ]; then
    curl -LSs "https://raw.githubusercontent.com/sidex15/KernelSU-Next/next-susfs/kernel/setup.sh" | bash -
else
    echo -e "${GREEN}[!]kernelsu ready.... ${NC}"
fi

# clone clang
if [ ! -d "$(pwd)/toolchain" ]; then
    git clone --depth=1 https://gitlab.com/neel0210/toolchain.git
else
    echo -e "${GREEN}[!]clang sudah ready...${NC}"
fi

# clone AnyKernel3 kalau belum ada
if [ ! -d "$(pwd)/AnyKernel3" ]; then
    git clone -b a22x https://github.com/makruf1954/AnyKernel3.git AnyKernel3
else
    echo -e "${RED}[!]anykernel ready....${NC}"
fi

# variabel
export CROSS_COMPILE=$(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-androidkernel-
export CC=$(pwd)/toolchain/clang/host/linux-x86/clang-r383902/bin/clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export ARCH=arm64
export ANDROID_MAJOR_VERSION=t
export KCFLAGS=-w
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

# start build
make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y a22x_defconfig
make -C $(pwd) O=$(pwd)/out KCFLAGS=-w CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j$(nproc --all)

# copy hasil build ke AnyKernel3
if [ -f "$(pwd)/out/arch/arm64/boot/Image.gz-dtb" ]; then
    cp $(pwd)/out/arch/arm64/boot/Image.gz-dtb $(pwd)/AnyKernel3/
elif [ -f "$(pwd)/out/arch/arm64/boot/Image.gz" ]; then
    cp $(pwd)/out/arch/arm64/boot/Image.gz $(pwd)/AnyKernel3/
elif [ -f "$(pwd)/out/arch/arm64/boot/Image" ]; then
    cp $(pwd)/out/arch/arm64/boot/Image $(pwd)/AnyKernel3/
else
    echo "Build gagal: tidak ada Image.gz/dtb ditemukan."
    exit 1
fi

# zip hasil
cd AnyKernel3
zip -r9 "../AnyKernel3-$(date +%Y%m%d-%H%M).zip" ./*
cd ..

