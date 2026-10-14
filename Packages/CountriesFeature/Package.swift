// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CountriesFeature",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "CountriesDomain", targets: ["CountriesDomain"]),
        .library(name: "CountriesData", targets: ["CountriesData"])
    ],
    dependencies: [
        .package(path: "../Networking"),
        .package(path: "../CountriesAPI"),
        .package(url: "https://github.com/apollographql/apollo-ios", exact: "2.4.0")
    ],
    targets: [
        .target(name: "CountriesDomain"),
        .target(
            name: "CountriesData",
            dependencies: [
                "CountriesDomain",
                .product(name: "Networking", package: "Networking"),
                .product(name: "CountriesAPI", package: "CountriesAPI"),
                .product(name: "ApolloAPI", package: "apollo-ios")
            ],
            exclude: ["GraphQL"]
        ),
        .testTarget(
            name: "CountriesDomainTests",
            dependencies: ["CountriesDomain"]
        ),
        .testTarget(
            name: "CountriesDataTests",
            dependencies: [
                "CountriesData",
                .product(name: "Networking", package: "Networking"),
                .product(name: "NetworkingTestSupport", package: "Networking"),
                .product(name: "CountriesAPI", package: "CountriesAPI")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
