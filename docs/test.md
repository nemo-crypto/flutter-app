# Flutter Starter 测试与发布

## 本地质量检查

```bash
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze --no-pub
flutter test --no-pub --coverage
```

Widget 测试覆盖加载失败与重试、窄屏与宽屏导航以及系统减少动态效果。设备集成测试覆盖任务表单校验、新增、完成、取消和确认清除、主题切换，以及抽卡示例的 Tab、单抽、十连和收藏筛选。

## Android 与 iOS 设备测试

```bash
flutter devices
scripts/device-test.sh <device-id>
```

| 设备 | 运行前准备 |
| --- | --- |
| Android Emulator | 在 Android Studio Device Manager 创建并启动 AVD。Apple Silicon 使用 ARM64 系统映像 |
| Android 真机 | 启用开发者选项和 USB 调试，连接后在设备上授权本机 |
| iOS Simulator | 通过 Xcode 安装 iOS runtime，用 `open -a Simulator` 启动模拟器 |
| iOS 真机 | 配对设备并启用 Developer Mode，在 Xcode 的 Runner target 选择 Team 和匹配的 Bundle Identifier |

在 iPhone 和 iPad 调整横竖屏、系统字号、深色模式和减少动态效果。真机回归时也检查软键盘遮挡、安全区、后台切回及 Android 返回键。设备脚本使用同一套 Flutter Integration Test，可在有已连接设备和签名配置的自托管 Runner 上执行。

iOS 的云端测试通过 `scripts/ios-simulator-test.sh <simulator-id>` 运行同一套流程，从模拟器读取测试结果。该命令需要 Xcode 和 `jq`。

## 更换应用身份

- Dart package 名称位于 `pubspec.yaml`，更名时同步替换 `package:flutter_starter/` 引用。
- Android 应用 ID 位于 `android/app/build.gradle.kts`，显示名位于 `android/app/src/main/AndroidManifest.xml`。如果同时改 `namespace`，同步迁移 `MainActivity.kt` 的包和路径。
- iOS 在 `ios/Runner.xcworkspace` 的 Runner target 设置 Bundle Identifier 与 Team。显示名位于 `ios/Runner/Info.plist`。
- 启动图标位于 Android `res/mipmap-*`、iOS `Assets.xcassets/AppIcon.appiconset` 和 `web/icons`。
- 在 `pubspec.yaml` 维护版本号。商店构建号须比已分发版本递增。

## 持续集成与交付

[Flutter CI](../.github/workflows/ci.yml) 在 PR、主分支更新或手动触发时运行。Actions 的运行详情可下载 `android-debug-apk`、`ios-simulator-app` 和覆盖率报告。APK 可用 `adb install -r app-debug.apk` 安装。解包 iOS 产物后可运行 `xcrun simctl install booted Runner.app`。

在 GitHub 新仓库的 **Settings → Pages** 选择 **GitHub Actions**，即可使用已有工作流把模板部署到项目根目录，抽卡示例部署到 `/gacha/`。工作流自动读取仓库名生成项目站点的 base href。

### Android 签名

本地复制 `android/key.properties.example` 到 `android/key.properties`，配置 upload keystore、alias 与密码。再运行 `flutter build appbundle --release`，产物位于 `build/app/outputs/bundle/release/`。

[签名工作流](../.github/workflows/android-release.yml) 从 GitHub Actions 的 `android-release` environment 读取以下 Secrets。

| Secret | 内容 |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | 上传密钥库文件的 Base64 |
| `ANDROID_STORE_PASSWORD` | 密钥库密码 |
| `ANDROID_KEY_ALIAS` | 上传密钥别名 |
| `ANDROID_KEY_PASSWORD` | 密钥密码 |

在 Actions 手动运行 **Build signed Android bundle** 并填写 build number。签名验证通过后下载 AAB，在 Play Console 分发。

### iOS 签名

在 Xcode 打开 `ios/Runner.xcworkspace`，为 Runner 配置自己的 Team 和发布 Bundle Identifier。装好分发证书与对应 Provisioning Profile 后运行 `flutter build ipa --release`，也可通过 Xcode Archive 导出。把签名后的 IPA 上传 TestFlight 或 App Store Connect。CI 默认上传可安装到模拟器的构建。
