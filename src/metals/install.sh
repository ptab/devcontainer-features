#!/bin/sh -eu

echo "Installing Coursier..."
curl -fL "https://github.com/VirtusLab/coursier-m1/releases/latest/download/cs-aarch64-pc-linux.gz" | gzip -d >/usr/local/bin/coursier
chmod +x /usr/local/bin/coursier
/usr/local/bin/coursier setup --yes

echo "Coursier and apps installed successfully."
