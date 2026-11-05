#!/bin/bash
set -e

echo "=== [1/4] Installing Flutter SDK ==="
if [ ! -d "/tmp/flutter" ]; then
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git /tmp/flutter
fi

export PATH="/tmp/flutter/bin:$PATH"

echo "=== [2/4] Configuring Flutter ==="
flutter config --enable-web --no-analytics

echo "=== [3/4] Installing Dependencies ==="
flutter pub get

echo "=== [4/4] Building Flutter Web Release ==="
flutter build web --release --no-tree-shake-icons

echo "=== Mirroring build/web to public/ ==="
rm -rf public
mkdir -p public
cp -R build/web/* public/

echo "=== Vercel Build Finished Successfully! ==="
