// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "IconPickerKit",
    platforms: [
        .iOS(.v26),
        .macOS(.v26),
    ],
    products: [
        .library(
            name: "IconPickerKit",
            targets: ["IconPickerKit"]),
        .library(
            name: "IconPickerKitIntelligence",
            targets: ["IconPickerKitIntelligence"]),
        .executable(
            name: "IconPickerKitDemo",
            targets: ["IconPickerKitDemo"]),
    ],
    targets: [
        .target(
            name: "IconPickerKit"),
        // Only this target imports FoundationModels, so apps without suggestions never load it.
        .target(
            name: "IconPickerKitIntelligence",
            dependencies: ["IconPickerKit"]),
        .executableTarget(
            name: "GenerateMedia",
            dependencies: ["IconPickerKit"]),
        .executableTarget(
            name: "IconPickerKitDemo",
            dependencies: ["IconPickerKit", "IconPickerKitIntelligence"],
            exclude: ["Info.plist"]),
        .testTarget(
            name: "IconPickerKitTests",
            dependencies: ["IconPickerKit", "IconPickerKitIntelligence"]),
    ])
