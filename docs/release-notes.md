Download **SHIORI.dmg** below. Requires macOS 14 or later, on Apple silicon or Intel.

1. Quit any older SHIORI instance.
2. Open the DMG and drag **SHIORI.app** onto **Applications**.
3. Eject the disk image and open SHIORI from Applications. SHIORI appears in the menu bar and at the screen edge.

This app is ad-hoc signed, not Developer ID signed or notarized by Apple. macOS may block the first launch because the developer cannot be verified or Apple cannot check it for malicious software. Only if you trust this download, try opening it once, then go to **System Settings → Privacy & Security → Open Anyway**, authenticate and confirm **Open** if offered. See [Apple's instructions](https://support.apple.com/en-ie/102445). Do not disable Gatekeeper or remove quarantine attributes. If macOS reports malware or damage, stop and report the warning.

To verify the download, place both attached files in the same folder and run:

```sh
shasum -a 256 -c SHIORI.dmg.sha256
```

See the [README](https://github.com/ITS-MSW/SHIORI#setup) for shortcuts, Accessibility permissions and local data storage.
