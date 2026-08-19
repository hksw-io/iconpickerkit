#!/bin/sh
set -euo pipefail
cd "$(dirname "$0")/.."

swift build --product IconPickerKitDemo
bin="$(swift build --show-bin-path)"
app="$bin/IconPickerKitDemo.app"

rm -rf "$app"
mkdir -p "$app/Contents/MacOS"
cp "$bin/IconPickerKitDemo" "$app/Contents/MacOS/"
cp Sources/IconPickerKitDemo/Info.plist "$app/Contents/Info.plist"
printf 'APPL????' > "$app/Contents/PkgInfo"

open "$app"
