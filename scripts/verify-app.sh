#!/bin/bash
set -euo pipefail
app=${1:?Usage: verify-app.sh /path/to/SHIORI.app}
plist="$app/Contents/Info.plist"
read_plist() { /usr/libexec/PlistBuddy -c "Print :$1" "$plist"; }
[[ "$(read_plist CFBundleIdentifier)" == app.shiori.desktop ]] || exit 1
[[ "$(read_plist LSMinimumSystemVersion)" == 14.0 ]] || exit 1
[[ "$(read_plist LSUIElement)" == true ]] || exit 1
[[ "$(read_plist ATSApplicationFontsPath)" == Fonts/ ]] || exit 1
[[ -s "$app/Contents/Resources/LICENSE" && -s "$app/Contents/Resources/THIRD_PARTY_NOTICES.md" ]] || exit 1
[[ -d "$app/Contents/Resources/Fonts" ]] || exit 1
# Check every Mach-O, including any future embedded frameworks, for both slices.
while IFS= read -r -d '' binary; do
  if file -b "$binary" | grep -q 'Mach-O'; then
    lipo "$binary" -verify_arch arm64 x86_64
    lipo -archs "$binary"
    for arch in arm64 x86_64; do
      xcrun vtool -arch "$arch" -show-build "$binary" | grep -Eq 'minos 14\.0$'
    done
  fi
done < <(find "$app" -type f -print0)
lipo "$app/Contents/MacOS/$(read_plist CFBundleExecutable)" -verify_arch arm64 x86_64
codesign --verify --deep --strict --verbose=2 "$app"
codesign -d --verbose=2 "$app" 2>&1
printf 'Verified SHIORI %s (%s), macOS 14.0, arm64 + x86_64\n' "$(read_plist CFBundleShortVersionString)" "$(read_plist CFBundleVersion)"
