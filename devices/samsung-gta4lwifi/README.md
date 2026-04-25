# Samsung Galaxy Tab A7 (SM-T500) Standalone Kernel Environment

### ⚠️ Hardware Warning

This environment was specifically developed and tested on the **Samsung Galaxy Tab A7 Model SM-T500 (gta4lwifi)**. While the kernel sources for Samsung devices are often shared across variants, proceed with caution if your model differs. The kernel configuration and patches provided are tailored for the SM-T500 and may not be compatible with other variants.

However, if you're lucky, the environment may be complete for your specific model as well. You can attempt to use your own configuration by extracting the `config.gz` file pulled from your device and moving it to `.config` under the kernel path:

```bash
cd /workspace/kernel/samsung/sm6115
# Place your extracted config here as .config
```

You can then test if the kernel compiles successfully for your model and results in a booting device. If it works, please create an issue on GitHub so the device entry can be slightly modified to account for the new model and have better automation for your device.

---

## Prerequisites

### Container Tooling
To use this environment, you must have **Podman** installed on your host system. 
* While other containerization tools (like Docker) that interface with standard `Containerfiles` may work, they are **strictly out of scope** for this guide. We will only provide support and instructions for Podman.

### Heimdall
Unlike most Android devices, Samsung uses the **Odin/Download mode** protocol. You will need `heimdall` installed on your host machine to flash the resulting kernel images.

---

## Step 1: Building and Entering the Environment

1. **Build the Container Image**:
   Navigate to the `samsung-gta4lwifi` directory and run:
   ```bash
   podman build -t samsung-kernel-builder .
   ```

2. **Start the Container**:
   Mount your local work directory to the container's `/workspace`:
   ```bash
   podman run -it --rm -v $(pwd):/workspace:Z samsung-kernel-builder
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

* **config.gz**: This is the stock configuration file pulled directly from a device running **LineageOS**. The `setup_env.sh` script automatically extracts this to `/workspace/kernel/samsung/sm6115/.config`.

To compile the kernel, navigate to the kernel source and run:
```bash
cd /workspace/kernel/samsung/sm6115
make -j$(nproc) Image.gz
```

---

## Step 4: Repacking the Boot Image

The file `kernel_work.tar.zst` contains the necessary tools and a stock boot image for the SM-T500.

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
    The folder includes `stock_boot.img`. Unpack it using the tool you just moved:
    ```bash
    ./magiskboot unpack stock_boot.img
    ```

4.  **Replace the Kernel**:
    Replace the unpacked kernel file with your newly recompiled Image:
    ```bash
    cp /workspace/kernel/samsung/sm6115/arch/arm64/boot/Image.gz kernel
    ```

5.  **Repack the Image**:
    ```bash
    ./magiskboot repack stock_boot.img new_boot.img
    ```

---

## Step 5: Testing and Flashing (Host Machine)

Exit the container. The `new_boot.img` will be located in your local `kernel_work` folder.

### ⚠️ CRITICAL: The stock_boot.img Backup
> [!IMPORTANT]
> **Do not delete the `stock_boot.img` file.** This is your only fallback if the new kernel fails to boot. If you delete this file and the `kernel_work.tar.zst` archive, you will have to find a matching boot image online. If you are offline when a boot failure occurs, you will be unable to restore your device.

### 1. Flash the New Kernel
Heimdall does not support a "live boot" feature like fastboot. You must flash the image to test it:
```bash
heimdall flash --BOOT new_boot.img
```

### 2. Recovery Procedure (If it doesn't boot)
If the device hangs at the splash screen or bootloops:
1.  **Enter Download Mode**: With the device powered off, hold **Volume Down + Volume Up** and connect the USB cable to your PC.
2.  **Flash Stock Kernel**:
    ```bash
    heimdall flash --BOOT stock_boot.img
    ```
Once restored, you can return to the container to adjust your configuration and try again.

---

## Included Artifacts

| File | Description |
| :--- | :--- |
| `config.gz` | Stock kernel config. |
| `kernel_work.tar.zst` | Contains `magiskboot` and `stock_boot.img` (SM-T500 only). |
| `standalone_fixes.patch` | Fixes for standalone Samsung kernel builds. |
| `setup_env.sh` | Automates cloning and patching. |
| `restore_env.sh` | Sets `PATH`, `ARCH`, and `LLVM` variables. |

---

*Found a bug or a missing config? Feel free to open an issue in the main Kernel-Foundry repository.*
