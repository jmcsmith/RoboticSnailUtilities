// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "RoboticSnailUtilities",
    platforms: [.iOS(.v18)],
    products: [
        .library(
            name: "RoboticSnailUtilities",
            targets: ["RoboticSnailUtilities"]),
    ],
    targets: [
        .target(
            name: "RoboticSnailUtilities"),
        .testTarget(
            name: "RoboticSnailUtilitiesTests",
            dependencies: ["RoboticSnailUtilities"]),
    ]
)
