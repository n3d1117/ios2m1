// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ios2m1",
    platforms: [
        .macOS(.v10_11)
    ],
    products: [
        .executable(name: "ios2m1", targets: ["ios2m1"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0"))
    ],
    targets: [
        .target(name: "ios2m1", dependencies: [
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
            "ZIPFoundation"
        ])
    ]
)
