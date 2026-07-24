# Screenshot

A macOS screenshot utility built with Swift.

## Download

[**Download Screenshot.dmg**](https://github.com/oofnivek/foo-kevn-screenshot/releases/latest/download/Screenshot.dmg) (latest release)

Open the `.dmg`, drag `Screenshot.app` into `Applications`. Since the app is signed with a local, non-notarized certificate rather than an Apple Developer ID (see [Gatekeeper note](#creating-a-distributable-dmg)), the first time you open it you'll need to right-click the app and choose **Open**, or allow it in **System Settings → Privacy & Security**.

## Requirements

- macOS 13 (Ventura) or later
- Xcode 15+ / Swift 5.9+ toolchain (`swift build` must be available in your `PATH`)

## Building from source

1. Clone the repository:

   ```sh
   git clone <repo-url>
   cd foo-kevn-screenshot
   ```

2. Create a local code-signing certificate named `Screenshot Dev` (one-time setup, see below).

3. Build and package the app:

   ```sh
   ./build_app.sh          # debug build
   ./build_app.sh release  # release build
   ```

   This compiles the Swift package, assembles `Screenshot.app` under `.build/<config>/`, and code-signs it.

4. Launch it:

   ```sh
   open .build/debug/Screenshot.app
   ```

## Creating the local signing certificate

The app requests Screen Recording permission from macOS. TCC (macOS's permission system) ties that grant to the app's code signature, so every rebuild needs the *same* signature — otherwise you'd have to re-approve permissions after each build. `swift build`'s default ad-hoc signature is a hash of the binary and changes every time, so `build_app.sh` instead signs with a stable, self-signed certificate you create once:

1. Open **Keychain Access** (`Applications/Utilities/Keychain Access.app`).
2. Menu bar: **Keychain Access → Certificate Assistant → Create a Certificate…**
3. Set:
   - **Name**: `Screenshot Dev`
   - **Identity Type**: Self Signed Root
   - **Certificate Type**: Code Signing
4. Click **Create**, accept the defaults, and close the assistant.
5. (Optional but recommended) In Keychain Access, find the new `Screenshot Dev` certificate, double-click it, expand **Trust**, and set **Code Signing** to **Always Trust**. This avoids an "untrusted developer" prompt the first time you launch the app.

Once the certificate exists in your keychain, `build_app.sh` will find it by name and sign the app automatically on every build.

## Granting Screen Recording permission

The first time you run the app and try to capture a screenshot, macOS will prompt you to grant **Screen Recording** access. Approve it in **System Settings → Privacy & Security → Screen Recording**. Because the app is signed with the stable `Screenshot Dev` certificate, this permission persists across rebuilds — you won't need to re-grant it unless you delete and recreate the certificate.

## Creating a distributable .dmg

To package a release build into a `.dmg` (the format apps are normally downloaded in):

```sh
./build_dmg.sh
```

This builds the release app, then creates `.build/release/Screenshot.dmg` containing `Screenshot.app` alongside a shortcut to `/Applications`, so anyone who opens it can drag the app in to install.

**Note on Gatekeeper:** `Screenshot.app` is signed with the local, self-signed `Screenshot Dev` certificate described above, not an Apple Developer ID, and it isn't notarized. That's fine for your own machines, but if you share the `.dmg` with someone else, macOS Gatekeeper will block it as "from an unidentified developer." They'll need to right-click the app and choose **Open** (or allow it in **System Settings → Privacy & Security**) the first time. To distribute without that warning, you'd need an Apple Developer ID certificate and to notarize the app with `notarytool`.

## Project structure

- `Sources/Screenshot/` — application source
- `Resources/` — `Info.plist` and app icon
- `build_app.sh` — build + packaging + signing script
- `build_dmg.sh` — packages a release build into a `.dmg`
- `Package.swift` — Swift Package Manager manifest
