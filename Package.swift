// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "AdortbSDK",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "AdortbSDK",
            targets: ["AdortbSDK"]
        ),
    ],
    targets: [
        .target(
            name: "AdortbSDK",
            dependencies: [],
            path: "Sources/AdortbSDK"
        ),
        .testTarget(
            name: "AdortbSDKTests",
            dependencies: ["AdortbSDK"],
            path: "Tests/AdortbSDKTests"
        ),
    ]
)
