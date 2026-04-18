# Motorola Edge 2021 (XT2141-2) Standalone Kernel Environment

### ⚠️ Hardware Warning

This environment was specifically developed and tested on the **Motorola Edge 2021 Model XT2141-2**. While this is generally the only model for this device, if your model differs, proceed with caution. The kernel configuration and patches provided are tailored for the XT2141-2 and may not be compatible with other variants.

However, if you're lucky, the environment may be complete for your specific model as well. You can attempt to use your own configuration by extracting the `config.gz` file pulled from your device and moving it to `.config` under the kernel path:

```bash
cd /workspace/kernel/motorola/sm7325
# Place your extracted config here as .config
```

You can then test if the kernel compiles successfully for your model and results in a booting device. If it works, please create an issue on GitHub so the device entry can be slightly modified to account for the new model and have better automation for your device.

---

## Prerequisites

### Container Tooling
To use this environment, you must have **Podman** installed on your host system. 
* While other containerization tools (like Docker) that interface with standard `Containerfiles` may work, they are **strictly out of scope** for this guide. We will only provide support and instructions for Podman.

### Fastboot
You will need `fastboot` installed on your host machine to test and flash the resulting kernel images.

---

## Step 1: Building and Entering the Environment

1. **Build the Container Image**:
   Navigate to the `motorola-berlna` directory and run:
   ```bash
   podman build -t lineage-kernel-builder .
   ```

2. **Start the Container**:
   Mount your local work directory to the container's `/workspace`:
   ```bash
   podman run -it --rm -v $(pwd):/workspace:Z lineage-kernel-builder
   ```

---

## Step 2: Initial Setup (Inside the Container)

Once you are inside the container, you must prepare the source code and environment.

1. **One-Time Setup**:
   Run the setup script to clone the pinned kernel sources, toolchains, and apply the `standalone_fixes.patch`. This only needs to be run **once**.
   ```bash
   ./setup_env.sh
   ```

2. **Initialize Environment Variables**:
   You must run this command **every time** you enter the container or open a new shell to set the correct paths for Clang and the architecture:
   ```bash
   source restore_env.sh
   ```

---

## Step 3: Kernel Configuration & Compilation

* **config.gz**: This is the stock configuration file pulled directly from a device running **LineageOS 23.2**. The `setup_env.sh` script automatically extracts this to `/workspace/kernel/motorola/sm7325/.config`.

To compile the kernel, navigate to the kernel source and run:
```bash
cd /workspace/kernel/motorola/sm7325
make -j$(nproc)
```

---

## Step 4: Repacking the Boot Image

The file `kernel_work.tar.zst` contains the necessary tools and a stock boot image pulled from a device running LineageOS 23.2.

1.  **Extract the Work Folder**:
    ```bash
    tar -xf kernel_work.tar.zst
    ```

2.  **Move Magiskboot**:
    If you ran the `run.sh` script at the root of the project as instructed earlier and moved the `magiskboot` executable to the current device folder, move it into the work directory now:
    ```bash
    mv magiskboot kernel_work/
    cd kernel_work
    ```

3.  **Unpack the Stock Image**:
    The folder includes `stock_boot_a.img`. Unpack it using the tool you just moved:
    ```bash
    ./magiskboot unpack stock_boot_a.img
    ```

4.  **Replace the Kernel**:
    Replace the unpacked kernel file with your newly recompiled Image:
    ```bash
    cp /workspace/kernel/motorola/sm7325/arch/arm64/boot/Image kernel
    ```

5.  **Repack the Image**:
    ```bash
    ./magiskboot repack stock_boot_a.img new_boot.img
    ```

---

## Step 5: Testing and Flashing (Host Machine)

Exit the container. The `new_boot.img` will be located in your local `kernel_work` folder.

### 1. Test Without Flashing
It is highly recommended to boot the image temporarily to ensure Android initializes correctly and features (Wi-Fi, Touch, etc.) work:
```bash
fastboot boot new_boot.img
```

### 2. Flashing to Slots
The Motorola Edge 2021 uses **A/B partitioning**. When the system updates, the active slot changes. To ensure your custom kernel persists across both slots, flash it to both:

```bash
fastboot flash boot_a new_boot.img
fastboot flash boot_b new_boot.img
```

---

## Included Artifacts

| File | Description |
| :--- | :--- |
| `config.gz` | Stock LineageOS 23.2 kernel config. |
| `kernel_work.tar.zst` | Contains `magiskboot` and `stock_boot_a.img`. |
| `standalone_fixes.patch` | Fixes for Qualcomm techpack and WALT drivers for standalone builds. |
| `setup_env.sh` | Automates cloning and patching. |
| `restore_env.sh` | Sets `PATH`, `ARCH`, and `LLVM` variables. |

---

*Found a bug or a missing config? Feel free to open an issue in the main Kernel-Foundry repository.*
