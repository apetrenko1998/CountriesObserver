// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CountriesFeature",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "CountriesDomain", targets: ["CountriesDomain"])
    ],
    targets: [
        .target(name: "CountriesDomain"),
        .testTarget(
            name: "CountriesDomainTests",
            dependencies: ["CountriesDomain"]
        )
    ],
    swiftLanguageModes: [.v6]
)
