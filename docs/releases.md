# macOS distribution

The checked-in Xcode project owns app configuration. `project.yml` remains its XcodeGen source. Neither is rewritten by packaging. Versions must match in both before a release. `Package.resolved` is committed and package resolution is frozen during distribution builds. Fonts, licenses, bundle identity, menu-bar behavior, hardened runtime and ad-hoc signing remain intact.

## Local build

Use Xcode 26.4 or 26.4.1, with its command-line tools selected. CI pins Xcode 26.4.1 on `macos-26`. If necessary, select it for just this command with `DEVELOPER_DIR=/Applications/Xcode_26.4.1.app/Contents/Developer`.

```sh
scripts/release.sh
cd build/distribution
shasum -a 256 -c SHIORI.dmg.sha256
open SHIORI.dmg
```

Outputs are always `build/distribution/SHIORI.dmg` and `SHIORI.dmg.sha256`. Each run builds into a fresh work directory under that folder; previous builds are preserved. `scripts/release.sh` owns the build, `scripts/verify-app.sh` owns bundle checks, and `scripts/package-dmg.sh` owns packaging and final-image checks. The latter also allows repackaging an already verified app without rebuilding. Its `build.log` is available for diagnosis. Python 3.10+ is required. Packaging installs `dmgbuild` and its two dependencies at pinned versions into an isolated venv under `build/distribution/`. It writes the Finder layout directly, so CI does not need Finder automation or UI permissions.

The script builds Release with `arm64 x86_64`, `ONLY_ACTIVE_ARCH=NO` and macOS 14.0, verifies every Mach-O's slices and minimum OS, verifies the bundle's configuration and signature, and packages a compressed read-only HFS+ image. It mounts the final image, checks the Applications symlink, layout files, signature and architectures, and compares the packaged app with the build before emitting the checksum. Packaging does not launch the app or modify installed copies or user data.

Reproducible here means pinned inputs and repeatable build/package commands, not byte-identical DMGs. Xcode, signatures, filesystem metadata and disk images can include timestamps. Use the same Xcode patch version for closest parity. Runner images can retire Xcode versions; update the explicit pin and reverify when needed.

## Publishing releases

1. Review and merge the intended release changes into `main` through your normal Git process. No release is created by merging.
2. Choose the next unused stable version, for example `1.0.2`. Update `MARKETING_VERSION` and increment `CURRENT_PROJECT_VERSION` in both `project.yml` and `SHIORI.xcodeproj/project.pbxproj`. Update the landing-page version. Review `docs/release-notes.md` and add the actual release changes. Commit and push through your normal review process.
3. After explicit approval to create the tag, run `git tag -a v1.0.2 -m 'SHIORI 1.0.2'` on the reviewed commit and `git push origin v1.0.2`. The tag must match the app version. Do not reuse existing version tags.
4. Open the macOS DMG release workflow run in Actions. It must pass before review. It creates a **draft**, attaching exactly `SHIORI.dmg` and `SHIORI.dmg.sha256`. Reruns may replace assets on drafts; published releases are rejected.
5. Download both draft assets, verify the checksum, open the DMG in Finder, confirm the layout, then drag the app to Applications. Quit the existing app before replacing it. Launch from Applications and verify menu-bar controls and notes. Ideally check on an Intel Mac and macOS 14 as well. Follow the first-launch instructions in the release notes. A locally built app does not reproduce downloaded-file quarantine behavior.
6. Review the draft notes and assets. After explicit publication approval, publish it as a **stable release** and select **Set as the latest release**. Do not mark it as a prerelease.
7. Confirm the following URL downloads the DMG successfully:
   `https://github.com/ITS-MSW/SHIORI/releases/latest/download/SHIORI.dmg`
8. The landing-page link is already enabled with the existing primary styling. No API, website edits or website deployment are needed for later stable releases: keep the exact asset name and mark each intended stable release as latest.

The first DMG release, `v1.0.1`, is published as the latest stable release with `SHIORI.dmg` and `SHIORI.dmg.sha256`. The public permanent download URL was fetched and compared byte-for-byte with the verified CI asset before enabling the website link.


## Signing later

The current app is ad-hoc signed and **not notarized**. The built-in signature verification checks integrity, not Gatekeeper approval. No Apple credentials or custom secrets are required; Actions uses its scoped repository token with `contents: write` only in the release job, required to create drafts and upload assets.

When Developer ID signing becomes available, replace the explicit ad-hoc signing settings in `scripts/release.sh` with the approved signing configuration. Sign the app before packaging; notarize and staple the app before copying it into the DMG. Then sign, notarize and staple the finished DMG before generating the checksum. Keep integrity, architecture and configuration checks, and add Gatekeeper assessment at that time. Never claim notarization based on an ad-hoc signature. No signing or notarization path is enabled today.

## Implementation verification

Local verification used Xcode 26.4, building SHIORI 1.0.1 (2). Release compilation succeeded for arm64 and x86_64; both slices report macOS 14.0. The final read-only DMG passed integrity verification, checksum verification, mounted signature verification and a recursive comparison with the build. Its Applications symlink resolves to `/Applications`. The branded layout was inspected in Finder and label contrast corrected. Packaging leaves the existing generic application icon unchanged.

During initial packaging work, SHIORI 1.0.0 was copied from the mounted image into the previously absent `/Applications/SHIORI.app`; the installed copy passed signature, architecture and contents checks. After installation approval, the debug instance was quit normally and `/Applications/SHIORI.app` was launched using computer use. Its edge-note container showed four existing notes and its menu commands were accessible. Native Intel execution, macOS 14 execution, and browser-download quarantine/first-launch behavior remain unverified. The tag-triggered GitHub Actions run for `v1.0.1` passed, and its downloaded DMG was mounted and independently checked before publication. Ad-hoc signing does not establish Gatekeeper approval.

Website typecheck and lint, shell syntax/ShellCheck, workflow actionlint, and `git diff --check` passed. No automated test suite was added. No tag, release publication or deployment is needed to merge this pipeline.
