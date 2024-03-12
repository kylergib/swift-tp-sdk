// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-tp",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TPSwiftSDK",
            targets: ["TPSwiftSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: Version("2.62.0")),
        .package(url: "https://github.com/kylergib/LoggerSwift", from: Version("1.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TPSwiftSDK",
            dependencies: [
                .product(name: "NIOCore", package: "swift-nio"), // Specify NIOCore here
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "LoggerSwift", package: "LoggerSwift")
            ]),
        .testTarget(
            name: "TPSwiftSDKTests",
            dependencies: ["TPSwiftSDK"]),
    ])
