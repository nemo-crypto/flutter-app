#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

simulator_id="${1:?Usage: scripts/ios-simulator-test.sh <simulator-id>}"
run_id=$(uuidgen)
app=build/ios/iphonesimulator/Runner.app
flutter build ios --simulator --debug --target=integration_test/ios_suite.dart \
  --dart-define="TEST_RUN_ID=$run_id"

bundle_id=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Info.plist")
xcrun simctl install "$simulator_id" "$app"
container=$(xcrun simctl get_app_container "$simulator_id" "$bundle_id" data)
report="$container/tmp/starter-tests-$run_id.json"
xcrun simctl launch --terminate-running-process "$simulator_id" "$bundle_id"
for ((attempt = 0; attempt < 120; attempt++)); do
  if [[ -f "$report" ]]; then
    jq . "$report"
    jq -e '.passed == true and (.results | length >= 2)' "$report" >/dev/null
    exit
  fi
  sleep 1
done

echo "Timed out waiting for Flutter UI test results on $simulator_id" >&2
exit 1
