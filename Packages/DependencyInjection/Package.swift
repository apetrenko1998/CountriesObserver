// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DependencyInjection",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "DependencyInjection", targets: ["DependencyInjection"])
    ],
    targets: [
        .target(name: "DependencyInjection"),
        .testTarget(
            name: "DependencyInjectionTests",
            dependencies: ["DependencyInjection"]
        )
    ],
    swiftLanguageModes: [.v6]
)
