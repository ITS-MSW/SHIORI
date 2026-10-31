#!/bin/bash
set -euo pipefail
app=$(cd "${1:?Usage: package-dmg.sh app output-directory}" && pwd)
mkdir -p "${2:?Output directory required}"
out=$(cd "$2" && pwd)
cd "$(dirname "$0")/.."
work=$(mktemp -d "$out/package.XXXXXX")
mount="$work/mount"
cleanup() {
  if /sbin/mount | grep -F " on $mount " > /dev/null; then hdiutil detach "$mount" || true; fi
}
trap cleanup EXIT
scripts/verify-app.sh "$app"
mkdir -p "$mount"
xcrun swift scripts/dmg-background.swift "$work/install.png"
python3 -m venv "$out/packaging-venv"
"$out/packaging-venv/bin/pip" install --disable-pip-version-check -r scripts/dmg-requirements.txt
"$out/packaging-venv/bin/dmgbuild" -s scripts/dmg-settings.py \
  -D app="$app" -D background="$work/install.png" SHIORI "$work/SHIORI.dmg"
hdiutil verify "$work/SHIORI.dmg"
hdiutil attach "$work/SHIORI.dmg" -mountpoint "$mount" -readonly -nobrowse
[[ -L "$mount/Applications" && "$(readlink "$mount/Applications")" == /Applications ]] || exit 1
[[ -s "$mount/.DS_Store" && -s "$mount/.background.png" ]] || exit 1
scripts/verify-app.sh "$mount/SHIORI.app"
diff -qr "$app" "$mount/SHIORI.app"
hdiutil detach "$mount"
# Only replace final outputs after every verification succeeds.
mv "$work/SHIORI.dmg" "$out/SHIORI.dmg"
(cd "$out" && shasum -a 256 SHIORI.dmg > SHIORI.dmg.sha256 && shasum -a 256 -c SHIORI.dmg.sha256)
echo "Distribution: $out/SHIORI.dmg"
