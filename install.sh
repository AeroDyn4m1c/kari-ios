#!/bin/sh
# kari installer for iSH (iPhone / iPad). Also works on Alpine / other Linux.
#   curl -sL https://raw.githubusercontent.com/AeroDyn4m1c/kari-ios/main/install.sh | sh
set -e

repo="${KARI_REPO:-AeroDyn4m1c/kari-ios}"
dest="${KARI_INSTALL_DIR:-/usr/local/bin}"

if command -v apk >/dev/null 2>&1; then
    echo "Installing dependencies (curl jq openssl fzf busybox-extras)..."
    apk add -q curl jq openssl fzf busybox-extras
else
    for d in curl jq openssl; do
        command -v "$d" >/dev/null 2>&1 || { echo "Please install $d first."; exit 1; }
    done
fi

mkdir -p "$dest"
echo "Downloading kari to $dest/kari..."
curl -sfL "https://raw.githubusercontent.com/$repo/main/kari" -o "$dest/kari"
chmod +x "$dest/kari"
echo "Done! Run: kari"
