// swift-tools-version:6.1

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
        .package(url: "https://github.com/swift-standards/swift-incits-4-1986.git", from: "0.0.1")
    ],
    targets: [
        .target(
            name: "RFC 2183",
            dependencies: [
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986")
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
