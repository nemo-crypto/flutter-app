#!/usr/bin/env bash
set -euo pipefail

version=$(<.flutter-version)
install_dir="${RUNNER_TEMP:?RUNNER_TEMP must be set}/flutter"
git clone --depth 1 --branch "$version" https://github.com/flutter/flutter.git "$install_dir"
echo "$install_dir/bin" >> "${GITHUB_PATH:?GITHUB_PATH must be set}"
