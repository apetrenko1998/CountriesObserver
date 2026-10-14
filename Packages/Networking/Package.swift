// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "Networking", targets: ["Networking"]),
        /// Test doubles for `GraphQLClient`. Link from test targets only.
        .library(name: "NetworkingTestSupport", targets: ["NetworkingTestSupport"])
    ],
    dependencies: [
        .package(url: "https://github.com/apollographql/apollo-ios", exact: "2.4.0")
    ],
    targets: [
        .target(
            name: "Networking",
            dependencies: [
                .product(name: "Apollo", package: "apollo-ios")
            ]
        ),
        .target(
            name: "NetworkingTestSupport",
            dependencies: [
                "Networking",
                .product(name: "ApolloAPI", package: "apollo-ios")
            ]
        ),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"]
        )
    ],
    swiftLanguageModes: [.v6]
)
