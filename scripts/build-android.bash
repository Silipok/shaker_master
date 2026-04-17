#!/bin/bash
# Build the Flutter Android app (APK and/or AAB).
# Usage: bash scripts/build-android.bash [--apk] [--aab] [--env dev|staging|prod] [--sentry-dsn DSN]
#
# Defaults: builds both APK and AAB, env=prod.
# Output lands in app/build/app/outputs/.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$REPO_ROOT/app"

BUILD_APK=false
BUILD_AAB=false
ENVIRONMENT="prod"
SENTRY_DSN=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apk)       BUILD_APK=true ;;
    --aab)       BUILD_AAB=true ;;
    --env)       ENVIRONMENT="$2"; shift ;;
    --sentry-dsn) SENTRY_DSN="$2"; shift ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

# Default: build both if neither flag was given.
if [[ "$BUILD_APK" == false && "$BUILD_AAB" == false ]]; then
  BUILD_APK=true
  BUILD_AAB=true
fi

DART_DEFINES="--dart-define=ENVIRONMENT=$ENVIRONMENT"
if [[ -n "$SENTRY_DSN" ]]; then
  DART_DEFINES="$DART_DEFINES --dart-define=SENTRY_DSN=$SENTRY_DSN"
fi

echo "Building Android — env=$ENVIRONMENT"

if [[ "$BUILD_APK" == true ]]; then
  echo "→ flutter build apk --release"
  (cd "$APP_DIR" && flutter build apk --release $DART_DEFINES)
  echo "APK → app/build/app/outputs/flutter-apk/app-release.apk"
fi

if [[ "$BUILD_AAB" == true ]]; then
  echo "→ flutter build appbundle --release"
  (cd "$APP_DIR" && flutter build appbundle --release $DART_DEFINES)
  echo "AAB → app/build/app/outputs/bundle/release/app-release.aab"
fi
