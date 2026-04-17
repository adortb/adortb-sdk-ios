# AdortbSDK iOS 架构文档

## SDK 内部架构

```
┌─────────────────────────────────────────────────────────────────┐
│                         App 层                                   │
│  ┌────────────┐  ┌──────────────────┐  ┌────────────────────┐  │
│  │ Banner     │  │ Native Ad        │  │ Custom UI          │  │
│  │ AdView     │  │ (App 自定义渲染) │  │                    │  │
│  └─────┬──────┘  └────────┬─────────┘  └────────────────────┘  │
└────────┼─────────────────┼────────────────────────────────────── ┘
         │                 │
         ▼                 ▼
┌─────────────────────────────────────────────────────────────────┐
│                      AdortbSDK (单例)                           │
│  configure() / loadNativeAd()                                   │
└────────────────────────┬────────────────────────────────────────┘
                         │
          ┌──────────────┼──────────────┐
          ▼              ▼              ▼
   ┌─────────────┐ ┌──────────────┐ ┌──────────────────┐
   │  AdLoader   │ │EventReporter │ │  PrivacyCompat   │
   │  (HTTP 请求)│ │ (事件上报)   │ │  (IDFA/ATT)      │
   └──────┬──────┘ └──────┬───────┘ └──────────────────┘
          │               │
          ▼               ▼
   ┌─────────────┐ ┌──────────────┐
   │ HTTPClient  │ │PersistentQueue│
   │(URLSession) │ │(UserDefaults) │
   └──────┬──────┘ └──────────────┘
          │
   ┌──────┼────────────────┐
   ▼                       ▼
ADX Server             Event Server
POST /v1/bid           POST /v1/event
:8080                  :8083
```

## 广告请求时序图

```
App                 AdortbSDK        AdLoader        ADX Server
 │                      │               │                │
 │  configure()         │               │                │
 │─────────────────────>│               │                │
 │                      │               │                │
 │  BannerAdView.load() │               │                │
 │─────────────────────>│               │                │
 │                      │ requestBid()  │                │
 │                      │──────────────>│                │
 │                      │               │  POST /v1/bid  │
 │                      │               │───────────────>│
 │                      │               │                │
 │                      │               │  BidResponse   │
 │                      │               │<───────────────│
 │                      │               │                │
 │                      │<──────────────│                │
 │  render Banner       │               │                │
 │<─────────────────────│               │                │
 │                      │               │                │
 │  [ImpressionTracker 50% 可见 1s]     │                │
 │─────────────────────>│ reportEvent(viewable)          │
```

## 事件上报流程图

```
用户操作/系统检测
      │
      ▼
EventReporter.report(type, slotID, deviceID)
      │
      ├──► 编码为 JSON EventPayload
      │
      ├──► HTTPClient.upload() → POST /v1/event
      │         │
      │         ├── 成功: 完成
      │         └── 失败: 放入 PersistentQueue
      │
      └──► PersistentQueue (UserDefaults, 最多 100 条)
                │
                └── App 下次启动时 replayPendingEvents()

EventPayload 结构:
{
  "type": "impression|click|viewable",
  "slot_id": "slot_xxx",
  "timestamp": 1700000000000,
  "app_bundle": "com.example.app",
  "device_id": "IDFA 或 IDFV"
}
```

## 隐私合规流程

```
初始化时
    │
    ▼
ATTrackingManager.trackingAuthorizationStatus
    │
    ├── authorized  ──► 使用 IDFA
    ├── denied      ──► 使用 IDFV + dnt=1
    ├── restricted  ──► 使用 IDFV + dnt=1
    └── notDetermined ► 使用 IDFV，等待用户响应
```
