#!/usr/bin/env bash
set -e

echo "🔄 Cleaning Flutter build…"
flutter clean

echo "📦 Getting pub packages…"
flutter pub get

echo "🛠 Building release APK…"
flutter build apk --release

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [[ -f "$APK_PATH" ]]; then
  echo " APK generated at: $APK_PATH"
else
  echo " Failed to generate APK"
  exit 1
fi
