# Flutter Starter

Flutter 与 Dart 的 Android、iOS 应用模板。克隆后可以用内置示例启动，包含 Material 3 主题、组件目录、动效、可替换的数据层和设备 UI 测试。

[在线体验](https://nemo-crypto.github.io/flutter-app/) · [抽卡业务示例](https://nemo-crypto.github.io/flutter-app/gacha/) · [测试与发布手册](docs/test.md)

## 快速开始

- Flutter **3.47.1**，版本记录在 [`.flutter-version`](.flutter-version)
- Android 使用 JDK 17、Android SDK 36 和 NDK 28.2.13676358，支持 Android 7.0 / API 24 及以上
- iOS 使用 macOS、Xcode 和 iOS Simulator，支持 iOS 15 及以上

```bash
git clone https://github.com/nemo-crypto/flutter-app.git
cd flutter-app
flutter doctor -v
flutter pub get --enforce-lockfile
flutter devices
flutter run -d <device-id>
```

`<device-id>` 替换为 `flutter devices` 输出的实际 ID。也可以运行 `flutter run -d chrome` 先看 Web 版本。Android 环境首次配置时按 `flutter doctor` 的提示完成 SDK 许可证确认。

默认进入任务示例。可以新增任务、标记完成、通过平台原生样式的弹窗清除已完成任务。**Components** 展示按钮、表单反馈、加载、空状态、错误重试和动画。**Settings** 可切换浅色、深色或跟随系统。任务与主题选择保存在当前应用会话，重启后从默认值开始。

## 拿来开发自己的 App

| 路径 | 职责 |
| --- | --- |
| [`lib/main.dart`](lib/main.dart) | 默认启动入口 |
| [`lib/app/starter_app.dart`](lib/app/starter_app.dart) | 应用装配、主题和自适应导航 |
| [`lib/ui/`](lib/ui/) | 可复用主题、间距、页面容器、反馈状态、平台弹窗和动效 |
| [`lib/features/tasks/`](lib/features/tasks/) | Repository、Controller 和页面的完整例子 |
| [`lib/core/network/`](lib/core/network/) | 可选的 JSON HTTP 适配，抽卡示例演示真实 API 接入 |
| [`integration_test/`](integration_test/) | 在模拟器和设备上运行的用户流程 |

添加一个业务功能时，可参考 `tasks/`。页面渲染状态并发送操作，Controller 处理请求、重复操作和失败状态，Repository 负责读取和更新数据。替换 `StarterApp.taskRepository` 可在 Widget 测试注入假数据，也可在应用入口接入本地存储或生产 API。

手机使用底部导航，宽度达到 720 逻辑像素时改用侧栏。UI 库提供安全区布局、键盘焦点管理、滚动表单、系统主题和减少动态效果支持。业务异步状态由 Controller 决定，动画仅用于展示。

准备发行自己的 App 时，更换 Android `applicationId`、iOS Bundle Identifier、App 图标与系统显示名。工程当前使用 `com.example.flutterstarter` 作为示例标识。[平台配置位置和签名步骤](docs/test.md)

## 运行抽卡示例

```bash
flutter run -d <device-id> --target lib/demo.dart
```

默认使用 Mock。开发真实后端时使用 `--dart-define=USE_MOCK_API=false` 和 `--dart-define=API_BASE_URL=https://api.example.com`。API 地址属于公开客户端配置。[示例架构](docs/project-structure.zh-CN.md) · [接口约定](docs/backend-api-contract.zh-CN.md)

## 自动化

提交 PR 后，GitHub Actions 检查格式及静态分析，运行单元和 Widget 测试，再在 Android Emulator 与 iOS Simulator 上验证任务和抽卡流程。通过后可下载 Android Debug APK、iOS Simulator App 和覆盖率报告。Web 模板和抽卡示例通过 GitHub Pages 工作流发布。可手动触发 Android 签名 AAB 构建。[设备测试与构建发布](docs/test.md)
