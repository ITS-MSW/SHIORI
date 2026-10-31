#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Keep local and CI builds on the same pinned toolchain family.
toolchain=$(xcodebuild -version)
[[ "${toolchain%%$'\n'*}" =~ ^Xcode\ 26\.4(\.1)?$ ]] || {
  echo 'Select Xcode 26.4 or 26.4.1 with DEVELOPER_DIR.' >&2; exit 1;
}
# The checked-in Xcode project is authoritative at build time.
version=$(sed -n 's/.*MARKETING_VERSION = \([^;]*\);/\1/p' SHIORI.xcodeproj/project.pbxproj | head -1)
if [[ $# -gt 0 && "$1" != "v$version" ]]; then
  echo "Expected tag v$version to match MARKETING_VERSION, got $1" >&2; exit 1
fi
out="$PWD/build/distribution"
mkdir -p "$out"
work=$(mktemp -d "$out/work.XXXXXX")
xcodebuild -project SHIORI.xcodeproj -scheme SHIORI -configuration Release \
  -destination 'generic/platform=macOS' -derivedDataPath "$work/DerivedData" \
  -onlyUsePackageVersionsFromResolvedFile -disableAutomaticPackageResolution \
  ARCHS='arm64 x86_64' ONLY_ACTIVE_ARCH=NO MACOSX_DEPLOYMENT_TARGET=14.0 \
  CODE_SIGN_IDENTITY=- CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM= build \
  > "$work/build.log" 2>&1 || { tail -80 "$work/build.log"; exit 1; }
app="$work/DerivedData/Build/Products/Release/SHIORI.app"
scripts/package-dmg.sh "$app" "$out"
echo "Build log: $work/build.log"
