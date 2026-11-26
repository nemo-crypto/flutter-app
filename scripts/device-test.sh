#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ $# -ne 1 || -z $1 ]]; then
  echo "Usage: $0 <device-id>" >&2
  flutter devices
  exit 2
fi

flutter test --no-pub -d "$1" integration_test/starter_test.dart integration_test/app_test.dart
