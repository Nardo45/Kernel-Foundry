#!/bin/bash
set -e

# Absolute paths for the Podman environment
BASE="/workspace"
KERNEL_PATH="$BASE/kernel/samsung/sm6115"
CLANG_PATH="$BASE/prebuilts/clang/host/linux-x86/clang-r416183b"

echo "Cloning Kernel Source..."
git clone --depth=1 -b lineage-23.2 https://github.com/LineageOS/android_kernel_samsung_sm6115.git "$KERNEL_PATH"
git -C "$KERNEL_PATH" checkout 646d493c15ede4e0429aee096ef7aebcbfee1764

echo "Cloning Clang Toolchain..."
git clone --depth=1 -b lineage-20.0 https://github.com/LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-r416183b.git "$CLANG_PATH"
git -C "$CLANG_PATH" checkout 54220fd601050b350b2af7adc913089ebf0e7aed

echo "Applying standalone build patches..."
if [ -f "$BASE/standalone_fixes.patch" ]; then
    patch -p1 -d "$KERNEL_PATH" < "$BASE/standalone_fixes.patch"
else
    echo "Error: $BASE/standalone_fixes.patch not found!"
    exit 1
fi

echo "Restoring kernel .config..."
if [ -f "$BASE/config.gz" ]; then
    zcat "$BASE/config.gz" > "$KERNEL_PATH/.config"
    echo "Kernel .config written to $KERNEL_PATH/.config"
else
    echo "Error: $BASE/config.gz not found!"
    exit 1
fi

echo -e "\nDone! Environment is locked and patched."
