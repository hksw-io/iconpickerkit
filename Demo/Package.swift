// swift-tools-version: 6.2
import PackageDescription

// The Mac-only demo app and media tool. They live outside the root package so that its
// tests build and run on iOS.
let package = Package(
    name: "IconPickerKitDemo",
    platforms: [
        .macOS(.v26),
    ],
    dependencies: [
        .package(name: "IconPickerKit", path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "IconPickerKitDemo",
            dependencies: [
                .product(name: "IconPickerKit", package: "IconPickerKit"),
                .product(name: "IconPickerKitIntelligence", package: "IconPickerKit"),
            ],
            exclude: ["Info.plist"]),
        .executableTarget(
            name: "GenerateMedia",
            dependencies: [
                .product(name: "IconPickerKit", package: "IconPickerKit"),
            ]),
    ])
