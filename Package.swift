// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ReactiveTesting",
    defaultLocalization: "en",
    platforms: [.iOS(.v17)],
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
