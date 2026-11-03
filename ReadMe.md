# Test

Test 是一个基于 Flutter 的纯前端抽卡 Demo，用于演示启动动画、四 Tab 页面、抽卡交互、图鉴筛选和前后端分离接入边界。

当前仓库只负责 Flutter 客户端，抽卡接口、用户数据、概率、资源扣除和保底持久化由独立后端服务负责。默认使用本地 Mock，因此不依赖后端也可以启动和验收 UI。

## Demo Features

- 启动时展示粒子、光环和品牌文字动画
- 底部四个 Tab：探索、抽卡、收藏、我的
- 抽卡页支持卡池切换、单抽、十连和结果动画
- 收藏页支持按 `N`、`R`、`SR`、`SSR` 筛选卡片
- 个人中心展示用户资料、等级进度、徽章和设置入口
- 真实后端可通过编译参数切换，页面不直接发 HTTP 请求

项目框架说明见 [`docs/project-structure.zh-CN.md`](docs/project-structure.zh-CN.md)。
后端接口约定见 [`docs/backend-api-contract.zh-CN.md`](docs/backend-api-contract.zh-CN.md)。

## Architecture and API

应用装配链路为：

```text
AppConfig -> AppBootstrap -> GachaRepository
          -> DemoGachaRepository / RemoteGachaRepository
          -> GachaController -> GachaPage / CollectionPage
```

- 默认 `USE_MOCK_API=true`，不依赖后端即可运行 Demo。
- 真实接口通过 `API_BASE_URL` 注入，页面不直接访问 HTTP。
- `GachaController` 统一处理加载、错误、重试、防重复抽卡和保底计数。
- Tab 页面按需创建，已访问页面通过 `IndexedStack` 保留状态。

## Environment

建议使用 Flutter stable 和 Dart 3.13 及以上环境。首次启动或修改依赖后执行：

```bash
flutter pub get
```

当前支持的编译期参数：

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `USE_MOCK_API` | `true` | `true` 使用本地 Mock，`false` 使用远程接口 |
| `API_BASE_URL` | 空 | 后端服务根地址，不要携带 `/v1/gacha` |
| `SKIP_SPLASH` | `false` | 是否跳过启动动画，适合自动化测试和快速联调 |

## Common Commands

### 1. Check devices

```bash
flutter devices
```

查看可用的 Android 模拟器、iOS 模拟器、真机和桌面设备。

### 2. Start with Mock

默认使用 Mock 启动：

```bash
flutter run --dart-define=USE_MOCK_API=true
```

指定设备启动：

```bash
flutter run -d <device-id>
```

跳过启动动画快速联调：

```bash
flutter run \
  --dart-define=SKIP_SPLASH=true \
  --dart-define=USE_MOCK_API=true
```

### 3. Start with real backend

关闭 Mock 并传入后端根地址：

```bash
flutter run \
  --dart-define=USE_MOCK_API=false \
  --dart-define=API_BASE_URL=https://api.example.com
```

前端会请求：

```text
GET  <API_BASE_URL>/v1/gacha/catalog
POST <API_BASE_URL>/v1/gacha/draw
```

具体 JSON 字段、错误格式和联调验收清单见 [`docs/backend-api-contract.zh-CN.md`](docs/backend-api-contract.zh-CN.md)。

### 4. Local development and hot reload

本地查看开发效果，建议直接运行 Flutter，而不是执行 `flutter build`：

```bash
flutter pub get
flutter devices
flutter run -d macos \
  --dart-define=USE_MOCK_API=true
```

也可以把 `macos` 替换为 Android 模拟器、iOS 模拟器或真机的设备 ID：

```bash
flutter run -d <device-id> \
  --dart-define=USE_MOCK_API=true
```

启动后，在运行 `flutter run` 的终端输入：

| 操作 | 终端按键 | 适用场景 |
| --- | --- | --- |
| Hot Reload | `r` | 修改 Widget `build`、颜色、布局和静态文案 |
| Hot Restart | `R` | 修改 Mock 数据、Repository、`initState`、路由或环境配置 |
| 停止运行 | `q` | 结束当前本地运行 |

当前项目的 `GachaController` 会在 `AppShell` 创建时加载一次卡池目录。修改 `DemoData`、`DemoGachaRepository`、`AppConfig`、`AppBootstrap` 或初始化逻辑后，普通 Hot Reload 不会重新执行初始化，必须使用大写 `R` Hot Restart；如果修改了 `pubspec.yaml`、Android/iOS 原生配置或插件，则需要停止后重新执行 `flutter run`。

如果页面仍然不更新，按下面顺序处理：

```bash
# 1. 确认当前命令是 flutter run，不是 flutter build
# 2. 在 flutter run 终端按大写 R
# 3. 仍然异常时重新生成依赖和运行缓存
flutter clean
flutter pub get
flutter run -d macos --dart-define=USE_MOCK_API=true
```

### 5. Quality checks and tests

静态分析：

```bash
flutter analyze
```

单元测试和 Widget 测试：

```bash
flutter test
```

Controller 单元测试重点覆盖卡池加载、失败重试、单抽/十连和防重复请求。

Integration/E2E 测试：

```bash
flutter test integration_test/app_test.dart
```

E2E 覆盖启动动画、四个底部 Tab、单抽、十连、结果更新、SSR 筛选和个人中心。跳过启动动画可缩短执行时间：

```bash
flutter test integration_test/app_test.dart \
  --dart-define=SKIP_SPLASH=true
```

### 6. Android build and package

Debug APK：

```bash
flutter build apk --debug
```

Release APK：

```bash
flutter build apk --release
```

Play Store 使用的 App Bundle：

```bash
flutter build appbundle --release
```

常见产物：

```text
build/app/outputs/flutter-apk/app-debug.apk
build/app/outputs/flutter-apk/app-release.apk
build/app/outputs/bundle/release/app-release.aab
```

### 7. iOS build and package

Debug/Release 构建：

```bash
flutter build ios --debug
flutter build ios --release
```

未配置签名时验证 iOS 工程编译：

```bash
flutter build ios --debug --no-codesign
```

生成 IPA：

```bash
flutter build ipa --release
```

真机或模拟器运行：

```bash
flutter run -d <ios-device-id>
```

iOS 打包需要 macOS、Xcode、有效签名证书和 provisioning profile。

### 8. macOS build and package

```bash
flutter run -d macos
flutter build macos --debug
flutter build macos --release
```

macOS 构建需要 macOS 和 Xcode。

### 9. Clean generated files

```bash
flutter clean
flutter pub get
```

当遇到旧构建产物、依赖异常或 Xcode/Gradle 缓存问题时使用。清理后建议重新执行 `flutter analyze` 和 `flutter test`。

## Performance Notes

- 启动动画约 2.9 秒，真实业务初始化在 `AppShell` 创建时触发；自动化可用 `SKIP_SPLASH=true`。
- `AppShell` 的其他 Tab 懒加载，避免首帧同时构建所有页面。
- 已访问页面由 `IndexedStack` 保留，减少重复初始化和滚动位置丢失。
- 主内容使用 `RepaintBoundary` 隔离重绘，卡面切换使用有限时长的 `AnimatedSwitcher`。
- 卡池目录只由一个 `GachaController` 持有，避免抽卡页和收藏页重复请求。
- 网络请求设置 8 秒超时，按钮在请求期间禁用，避免重复提交。
- 图鉴使用 `SliverGrid.builder`，页面滚动时只构建可见区域附近的卡片。

## Flavor Command Templates

当前项目还没有定义 flavor。只有在补齐 Android/iOS 的 flavor 配置、入口文件和签名配置后，才使用以下模板：

```bash
flutter run --flavor <flavor-name> -t lib/main_<flavor-name>.dart
flutter build apk --flavor <flavor-name> -t lib/main_<flavor-name>.dart
flutter build appbundle --flavor <flavor-name> -t lib/main_<flavor-name>.dart
flutter build ipa --flavor <flavor-name> -t lib/main_<flavor-name>.dart
```

示例入口：

```text
lib/main_dev.dart
lib/main_staging.dart
lib/main_prod.dart
```
