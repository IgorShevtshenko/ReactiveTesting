// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ReactiveTesting",
    defaultLocalization: "en",
    platforms: [.iOS(.v17), .macOS(.v10_15)],
    products: [
        .library(
            name: "ReactiveTesting",
            targets: ["ReactiveTesting"]
        ),
    ],
    targets: [
        .target(name: "ReactiveTesting"),
    ]
)
