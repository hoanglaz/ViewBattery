// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ViewBattery",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "ViewBattery",
            targets: ["ViewBattery"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "ViewBattery",
            path: "Sources/ViewBattery"
        ),
    ]
)
