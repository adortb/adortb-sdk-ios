# adortb iOS SDK

adortb 广告平台的 iOS Swift SDK，支持 Banner 和 Native 广告，兼容 iOS 13+。

## SDK 架构定位

```
┌──────────────────────────────────────────────┐
│              你的 iOS App                     │
│  ┌──────────────┐    ┌──────────────────┐    │
│  │ BannerAdView │    │    NativeAd      │    │
│  └──────┬───────┘    └────────┬─────────┘    │
│         └────────────┬────────┘              │
│              AdortbSDK (SDK)                 │
└──────────────────────┼───────────────────────┘
                       │
          ┌────────────┴────────────┐
          ▼                        ▼
  ADX Bid Server             Event Server
  POST /v1/bid               POST /v1/event
```

## 集成方式

### Swift Package Manager

在 `Package.swift` 中添加：

```swift
dependencies: [
    .package(url: "https://github.com/adortb/adortb-sdk-ios.git", from: "1.0.0")
]
```

或在 Xcode → File → Add Packages 中输入仓库地址。

## 快速开始

### 1. 初始化 SDK

在 `AppDelegate.application(_:didFinishLaunchingWithOptions:)` 中：

```swift
import AdortbSDK

AdortbSDK.shared.configure(
    publisherID: "pub_123",
    serverURL: URL(string: "http://your-adx-server:8080")!,
    eventServerURL: URL(string: "http://your-event-server:8083")!
)
```

### 2. 请求 Banner 广告

```swift
import AdortbSDK

let banner = BannerAdView(slotID: "slot_xxx", size: .banner320x50)
banner.load { result in
    switch result {
    case .success:
        print("Banner 加载成功")
    case .failure(let err):
        print("Banner 加载失败: \(err.localizedDescription)")
    }
}
view.addSubview(banner)
```

### 3. 请求 Native 广告

```swift
AdortbSDK.shared.loadNativeAd(slotID: "slot_yyy") { result in
    switch result {
    case .success(let nativeAd):
        // 使用 nativeAd.title / imageURL / clickURL 自定义渲染
        nativeAd.recordImpression()
        nativeAd.recordViewable()
    case .failure(let err):
        print("Native 加载失败: \(err.localizedDescription)")
    }
}
```

### 4. 隐私合规（推荐）

```swift
PrivacyCompat.shared.requestTrackingAuthorization { status in
    print("ATT 状态: \(status)")
    // 之后再初始化/请求广告
}
```

## 配置参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `publisherID` | String | 必填 | 媒体方 ID |
| `serverURL` | URL | 必填 | ADX Bid 服务地址 |
| `eventServerURL` | URL? | 与 serverURL 同主机:8083 | 事件上报地址 |
| `timeout` | TimeInterval | 3.0 | 请求超时时间（秒） |
| `debug` | Bool | false | 开启调试日志 |

## 广告尺寸

| 枚举值 | 宽 × 高 |
|--------|---------|
| `.banner320x50` | 320 × 50 |
| `.banner300x250` | 300 × 250 |
| `.banner728x90` | 728 × 90 |
| `.custom(width:height:)` | 自定义 |

## API 说明

### AdortbSDK
- `configure(publisherID:serverURL:eventServerURL:timeout:debug:)` — 初始化配置
- `loadNativeAd(slotID:completion:)` — 加载 Native 广告
- `isConfigured: Bool` — SDK 是否已初始化

### BannerAdView
- `init(slotID:size:)` — 创建 Banner 视图
- `load(completion:)` — 发起广告请求

### NativeAd
- `title`, `adDescription`, `imageURL`, `clickURL`, `sponsoredBy` — 素材字段
- `recordImpression()` — 手动记录展示
- `recordClick()` — 手动记录点击
- `recordViewable()` — 手动记录可见

### PrivacyCompat
- `requestTrackingAuthorization(completion:)` — 请求 ATT 授权
- `deviceID: String?` — IDFA（授权时）或 IDFV
- `dnt: Int` — 0 允许追踪，1 拒绝

## 系统要求

- iOS 13.0+
- Swift 5.9+
- Xcode 15+

## 架构文档

详见 [docs/architecture.md](docs/architecture.md)
