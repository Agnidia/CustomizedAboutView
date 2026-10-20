// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "CustomizedAboutView",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v26),
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
