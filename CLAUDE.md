# AdortbSDK iOS — AI 开发入口

## 项目概述

adortb iOS Swift SDK，为 iOS 13+ 应用提供 Banner 广告和 Native 广告的接入能力。

## 快速入手

```bash
swift build          # 编译
swift test           # 跑单元测试
```

## 核心文件

| 文件 | 职责 |
|------|------|
| `AdortbSDK.swift` | 公开单例入口，configure / loadNativeAd |
| `AdLoader.swift` | 构造 BidRequest 发送 HTTP 请求 |
| `BannerAdView.swift` | UIView 子类，加载渲染 Banner |
| `NativeAd.swift` | Native 广告数据对象 |
| `EventReporter.swift` | 展示/点击/可见事件上报 + 失败重试队列 |
| `ImpressionTracker.swift` | CADisplayLink 50% 可见 1 秒触发 |
| `DeviceInfo.swift` | 设备信息采集 |
| `PrivacyCompat.swift` | ATT 授权 / IDFA / IDFV |
| `Utils/HTTPClient.swift` | URLSession 封装 |

## 渐进式任务

- **新增广告位类型**: 扩展 `AdSlot.swift` + `BannerAdView` 或 新建 `InterstitialAdView`
- **优化事件重试**: 修改 `PersistentQueue`，可替换为 SQLite 存储
- **隐私扩展**: 在 `PrivacyCompat.swift` 中添加 GDPR TCF 字符串支持
- **测试扩展**: 在 `AdortbSDKTests.swift` 补充更多解析和集成测试

## 端点

- Bid: `POST {serverURL}/v1/bid`
- Event: `POST {eventURL}/v1/event`
