// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "swift-rfc-2183",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11)
    ],
    products: [
        .library(
            name: "RFC 2183",
            targets: ["RFC 2183"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-incits-4-1986.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-standards/swift-rfc-2045.git", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-rfc-5322.git", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "RFC 2183",
            dependencies: [
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986"),
                .product(name: "RFC 2045", package: "swift-rfc-2045"),
                .product(name: "RFC 5322", package: "swift-rfc-5322"),
            ]
        ),
        .testTarget(
            name: "RFC 2183 Tests",
            dependencies: ["RFC 2183"]
        )
    ]
)

for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(.enableUpcomingFeature("MemberImportVisibility"))
    target.swiftSettings = settings
}
