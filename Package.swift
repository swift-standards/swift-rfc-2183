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
    dependencies: [],
    targets: [
        .target(
            name: "RFC 2183",
            dependencies: []
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
