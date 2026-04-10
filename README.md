# Kernel-Foundry

**Kernel-Foundry** is a collection of containerized, standalone, and 100% reproducible Android kernel build environments. 

The primary goal of this project is to decouple Android kernel development from the massive AOSP/LineageOS source trees (300GB+). By using Podman and pinned Git commits, Kernel-Foundry allows you to compile device-specific kernels in a lightweight, isolated environment with only the necessary toolchains and sources.

---

## Key Features

* **AOSP-Free:** Build kernels without downloading the entire Android operating system source.
* **Reproducible:** Every environment uses specific Commit SHAs for kernels and toolchains to ensure "it builds on my machine" means "it builds on yours."
* **Containerized:** Built around Podman to keep your host system clean and dependencies isolated.
* **Patch-Ready:** Includes specific patches to bridge the gap between internal Android build systems and standalone GNU Make/Kbuild.

---

## 📂 Repository Structure

The project is organized by device manufacturer and codename to allow for easy scaling as more environments are added.

```text
.
├── devices/
│   └── motorola-berlna/     # Motorola Edge 2021 (XT2141-2 / sm7325)
│       ├── Containerfile       # Build environment definition
│       ├── setup_env.sh        # Clones and pins sources/toolchains
│       ├── restore_env.sh      # Sets environment variables
│       ├── standalone_fixes.patch
│       └── README.md           # Device-specific build instructions
└── README.md                   # This file
```

---

## 📱 Supported Devices

| Device | Model | Code-name | Status |
| :--- | :--- | :--- | :--- |
| **Motorola Edge 2021** | XT2141-2 | berlna | ✅ Stable |

---

## 🛠️ General Workflow

While each device has its own specific `README.md` inside its folder, the general workflow remains consistent:

1.  **Enter the Device Directory:**
    ```bash
    cd devices/your-device-name
    ```
2.  **Build the Environment:**
    ```bash
    podman build -t kernel-builder-name .
    ```
3.  **Run the Container:**
    ```bash
    podman run -it --rm -v $(pwd):/workspace kernel-builder-name
    ```
4.  **Setup & Build:**
    Inside the container, run the `setup_env.sh` (once) and `source restore_env.sh` (every session) before running `make`.

---

## 🤝 Contribution & Expansion

This project is designed to grow. If you have successfully decoupled a kernel from a vendor build system and verified it on physical hardware:

1.  Create a new directory under `devices/`.
2.  Include a `Containerfile` that provides the necessary build tools.
3.  Provide a `setup_env.sh` that pins the exact commits you used.
4.  Include any necessary `standalone_fixes.patch` files required for the build to succeed outside of AOSP.

---

## ⚖️ License

All kernel sources and toolchains are subject to their respective upstream licenses (GPLv2, Apache 2.0, etc.). The scripts and configuration files in this repository are provided "as-is" for the purpose of hardware experimentation and development.
