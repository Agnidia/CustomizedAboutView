// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CustomizedAboutView",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        .library(
            name: "CustomizedAboutView",
            targets: ["CustomizedAboutView"]
        ),
    ],
    targets: [
        .target(
            name: "CustomizedAboutView",
            resources: [.process("Resources")],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
        .testTarget(
            name: "CustomizedAboutViewTests",
            dependencies: ["CustomizedAboutView"],
            swiftSettings: [.swiftLanguageMode(.v6)]
        ),
    ]
)
