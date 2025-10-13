// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LaunchKit",
    platforms: [.macOS(.v15), .iOS(.v18)],
    products: [
        .library(
            name: "LaunchKit",
            targets: ["LaunchKit"]
        ),
        .library(
            name: "CLaunchKit",
            targets: ["CLaunchKit"]
        ),
        .executable(
            name: "launchctl",
            targets: ["launchctl"]
        ),
    ],
    targets: [
        .target(name: "CLaunchKit"),
        .target(name: "LaunchKit", dependencies: [.target(name: "CLaunchKit")]),
        .executableTarget(name: "launchctl", dependencies: [.target(name: "LaunchKit")])
    ]
)
