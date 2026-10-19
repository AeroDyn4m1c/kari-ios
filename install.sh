#!/bin/sh
# kari installer for iSH (iPhone / iPad). Also works on Alpine / other Linux.
#   curl -sL https://raw.githubusercontent.com/AeroDyn4m1c/kari-ios/main/install.sh | sh

repo="${KARI_REPO:-AeroDyn4m1c/kari-ios}"
dest="${KARI_INSTALL_DIR:-/usr/local/bin}"

if command -v apk >/dev/null 2>&1; then
    echo "Updating package lists..."
    apk update
    echo "Installing dependencies (curl jq openssl fzf)..."
    # apk can print "broken packages" warnings for unrelated packages; check the result below instead
    apk add curl jq openssl fzf
fi

missing=""
for d in curl jq openssl; do
    command -v "$d" >/dev/null 2>&1 || missing="$missing $d"
done
# kari's local server for VLC uses busybox nc -e (part of iSH's base system)
if command -v apk >/dev/null 2>&1 && ! busybox nc --help 2>&1 | grep -q 'persistent server'; then
    missing="$missing busybox"
fi
if [ -n "$missing" ]; then
    echo "Could not install:$missing"
    echo "Try: apk update && apk add$missing"
    exit 1
fi
command -v fzf >/dev/null 2>&1 || echo "Note: fzf is not installed, kari will use numbered menus instead."

mkdir -p "$dest"
echo "Downloading kari to $dest/kari..."
curl -sfL "https://raw.githubusercontent.com/$repo/main/kari" -o "$dest/kari" || { echo "Download failed."; exit 1; }
chmod +x "$dest/kari"
echo "Done! Run: kari"
