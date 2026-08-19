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
        .executable(
            name: "IconPickerKitDemo",
            targets: ["IconPickerKitDemo"]),
    ],
    targets: [
        .target(
            name: "IconPickerKit"),
        .executableTarget(
            name: "GenerateMedia",
            dependencies: ["IconPickerKit"]),
        .executableTarget(
            name: "IconPickerKitDemo",
            dependencies: ["IconPickerKit"],
            exclude: ["Info.plist"]),
        .testTarget(
            name: "IconPickerKitTests",
            dependencies: ["IconPickerKit"]),
    ])
