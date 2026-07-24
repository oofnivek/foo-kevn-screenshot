#!/bin/bash
# Builds Screenshot (release) and packages it into a distributable .dmg.
set -euo pipefail

cd "$(dirname "$0")"

CONFIG="release"
APP_NAME="Screenshot"
BUILD_DIR=".build/${CONFIG}"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
DMG_STAGING="${BUILD_DIR}/dmg-staging"
DMG_PATH="${BUILD_DIR}/${APP_NAME}.dmg"

echo "Building app bundle..."
./build_app.sh "${CONFIG}"

echo "Staging DMG contents..."
rm -rf "${DMG_STAGING}" "${DMG_PATH}"
mkdir -p "${DMG_STAGING}"
cp -R "${APP_BUNDLE}" "${DMG_STAGING}/"
ln -s /Applications "${DMG_STAGING}/Applications"

echo "Creating ${DMG_PATH}..."
hdiutil create -volname "${APP_NAME}" \
  -srcfolder "${DMG_STAGING}" \
  -ov -format UDZO \
  "${DMG_PATH}"

rm -rf "${DMG_STAGING}"

echo "Done. DMG at: ${DMG_PATH}"
