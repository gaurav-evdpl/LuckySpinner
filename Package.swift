// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LuckySpinner",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        // The library that other apps import via `import LuckySpinner`.
        .library(
            name: "LuckySpinner",
            targets: ["LuckySpinner"]
        )
    ],
    targets: [
        // The main SwiftUI source target. No external dependencies.
        .target(
            name: "LuckySpinner"
        ),
        // Unit tests for the package.
        .testTarget(
            name: "LuckySpinnerTests",
            dependencies: ["LuckySpinner"]
        )
    ]
)
