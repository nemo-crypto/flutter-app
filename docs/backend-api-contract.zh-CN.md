# 后端接口契约

本文定义 Flutter 前端当前使用的抽卡服务接口。后端服务独立部署，前端只通过 `GachaRepository` 消费数据，不在本项目内实现业务规则、概率计算、用户资产或保底持久化。

## 1. 环境配置

默认启动使用本地 Mock：

```bash
flutter run --target lib/demo.dart \
  --dart-define=USE_MOCK_API=true
```

联调真实后端时关闭 Mock 并传入服务地址：

```bash
flutter run --target lib/demo.dart \
  --dart-define=USE_MOCK_API=false \
  --dart-define=API_BASE_URL=https://api.example.com
```

`API_BASE_URL` 不要携带接口路径，前端会自动拼接 `/v1/gacha/catalog` 和 `/v1/gacha/draw`。

当前请求超时时间为 8 秒。超时、非 2xx 状态码和非法 JSON 都会进入页面错误状态，用户可以点击“重新加载”再次请求。

## 2. 获取卡池目录

### 请求

```http
GET /v1/gacha/catalog
Accept: application/json
```

### 成功响应

```json
{
  "banners": [
    {
      "id": "deep-space-echo",
      "title": "深空回响",
      "subtitle": "极光观测者 · 概率提升"
    }
  ],
  "cards": [
    {
      "id": "aurora",
      "name": "极光观测者",
      "subtitle": "限定 · 星辉序列",
      "rarity": "legendary",
      "symbol": "A-01",
      "primaryColor": "#25D0E6",
      "secondaryColor": "#725CFF",
      "icon": "auto_awesome",
      "isNew": true
    }
  ]
}
```

### 字段说明

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `banners` | `array` | 是 | 当前可抽取的卡池列表 |
| `banners[].id` | `string` | 是 | 卡池唯一标识，抽卡时原样回传 |
| `banners[].title` | `string` | 是 | 卡池名称 |
| `banners[].subtitle` | `string` | 是 | 卡池副标题 |
| `cards` | `array` | 是 | 图鉴和抽卡结果可展示的卡片列表 |
| `cards[].rarity` | `string` | 是 | `common`、`rare`、`epic` 或 `legendary` |
| `cards[].primaryColor` | `string` | 否 | 6 位或 8 位十六进制颜色 |
| `cards[].secondaryColor` | `string` | 否 | 6 位或 8 位十六进制颜色 |
| `cards[].icon` | `string` | 否 | 当前支持 `auto_awesome`、`nightlight_round`、`bolt`、`water_drop`、`public`、`graphic_eq` |
| `cards[].isNew` | `boolean` | 否 | 是否标记为新卡，默认 `false` |

空数组是合法 JSON，但前端会显示“暂无卡池数据”或“暂无图鉴数据”，不会认为请求成功后一定有可抽内容。

## 3. 抽卡

### 请求

```http
POST /v1/gacha/draw
Accept: application/json
Content-Type: application/json; charset=utf-8
```

```json
{
  "bannerId": "deep-space-echo",
  "count": 10
}
```

`count` 当前只允许 `1` 或 `10`。概率、消耗、库存、保底和用户身份校验全部由后端负责，前端不应自行计算最终结果。

### 成功响应

```json
{
  "card": {
    "id": "lunar",
    "name": "月面信使",
    "subtitle": "稀有 · 静海档案",
    "rarity": "epic",
    "symbol": "L-07",
    "primaryColor": "#FF76C8",
    "secondaryColor": "#7047D8",
    "icon": "nightlight_round",
    "isNew": false
  },
  "pityCount": 43
}
```

当前前端 UI 以单张 `card` 作为演示结果展示，因此十连接口暂时也返回一个主展示卡片。正式业务如果需要展示十张结果，建议后端增加 `cards` 数组，再由前端升级 DTO。

| 字段 | 类型 | 必填 | 说明 |
| --- | --- | --- | --- |
| `card` | `object` | 是 | 当前主展示结果，结构与目录中的卡片对象一致 |
| `pityCount` | `integer` | 是 | 后端计算后的当前保底计数，前端直接覆盖展示 |

## 4. 错误响应

建议所有 4xx/5xx 接口统一返回：

```json
{
  "code": "GACHA_BANNER_NOT_FOUND",
  "message": "卡池不存在或已结束",
  "detail": "deep-space-echo"
}
```

前端优先展示 `message`，其次兼容 `error` 和 `detail` 字段；没有可读错误信息时显示通用提示。HTTP 状态码仍然必须正确设置，成功范围为 `200` 至 `299`。

建议状态码：

| 状态码 | 场景 |
| --- | --- |
| `400` | 请求参数不合法 |
| `401` | 登录态失效或缺少认证 |
| `403` | 没有抽卡权限或资源不足 |
| `404` | 卡池不存在 |
| `409` | 抽卡状态冲突、重复提交或库存变化 |
| `429` | 频率限制 |
| `500` | 服务端内部错误 |

## 5. 对接边界

- `lib/core/network/` 只负责 HTTP、JSON、超时和状态码。
- `lib/features/gacha/data/remote_gacha_repository.dart` 负责路径、请求体和 DTO 转换。
- `GachaController` 负责加载状态、错误状态、当前卡池和 UI 所需的保底计数。
- Widget 不直接发 HTTP 请求，避免页面重建时重复请求。
- 真实鉴权 token 应在登录后由安全存储或会话层注入，不要把长期密钥写入 `--dart-define` 或提交到仓库。

## 6. 联调验收清单

1. `GET /v1/gacha/catalog` 返回至少一个有效卡池和一张卡片。
2. `POST /v1/gacha/draw` 能识别 `bannerId` 和 `count`，并返回 `card`、`pityCount`。
3. 服务端错误返回非 2xx 状态码和可读的 `message`。
4. 前端使用真实地址启动后，抽卡页能完成加载、单抽、十连和失败重试。
5. 不把概率、保底和资源扣除逻辑放到 Flutter 客户端。
