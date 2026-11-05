#!/bin/bash

set -e

# Install Flutter SDK
git clone --depth 1 \
  https://github.com/flutter/flutter.git \
  -b stable /tmp/flutter

export PATH="/tmp/flutter/bin:$PATH"

# Enable web
flutter config --enable-web

# Install dependencies
flutter pub get

# Build website
flutter build web --release