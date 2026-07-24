#!/bin/bash
# Builds ScreenShot and packages it into a proper, code-signed .app bundle.
#
# Signing with a stable local certificate (rather than swift build's default
# ad-hoc signature) is what lets Screen Recording permission survive rebuilds:
# TCC keys the grant to the code signature, and an ad-hoc signature is a hash
# of the binary that changes on every build.
set -euo pipefail

cd "$(dirname "$0")"

CONFIG="${1:-debug}"
APP_NAME="ScreenShot"
BUNDLE_ID="foo.kevn.screenshot"
SIGNING_IDENTITY="ScreenShot Dev"
BUILD_DIR=".build/${CONFIG}"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"

echo "Building (${CONFIG})..."
swift build -c "${CONFIG}"

echo "Packaging ${APP_BUNDLE}..."
rm -rf "${APP_BUNDLE}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

cp "${BUILD_DIR}/${APP_NAME}" "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"
cp Resources/Info.plist "${APP_BUNDLE}/Contents/Info.plist"
cp Resources/AppIcon.icns "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"

echo "Signing with \"${SIGNING_IDENTITY}\"..."
codesign --force --deep --options runtime \
  --sign "${SIGNING_IDENTITY}" \
  --identifier "${BUNDLE_ID}" \
  "${APP_BUNDLE}"

echo "Done. Launch with: open ${APP_BUNDLE}"
