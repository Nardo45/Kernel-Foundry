#!/bin/bash
set -e  # exit on any error

# URLs and filenames
MAGISK_URL="https://github.com/topjohnwu/Magisk/releases/download/v30.7/Magisk-v30.7.apk"
MAGISK_APK="Magisk-v30.7.apk"
MAGISK_DIR="Magisk-v30.7"

# Download Magisk APK
echo "Downloading Magisk APK..."
curl -L -o "$MAGISK_APK" "$MAGISK_URL"

# Extract the APK (it's a zip file)
echo "Extracting APK..."
unzip -q "$MAGISK_APK" -d "$MAGISK_DIR"

# Define source and destination
SOURCE="$MAGISK_DIR/lib/x86_64/libmagiskboot.so"
DEST="magiskboot"

# Copy and rename the binary
if [ -f "$SOURCE" ]; then
    cp "$SOURCE" "$DEST"
    chmod +x "$DEST"
    echo "Extracted and renamed to $DEST"
else
    echo "Error: $SOURCE not found"
    exit 1
fi

# Clean up
rm -rf "$MAGISK_APK" "$MAGISK_DIR"
echo "Cleanup done. $DEST is ready to use."
