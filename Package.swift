// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "swift-rfc-2183",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
    ],
    products: [
        .library(
            name: "RFC 2183",
            targets: ["RFC 2183"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-foundations/swift-ascii.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-standards/swift-rfc-2045.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-standards/swift-rfc-5322.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-binary-primitives.git", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "RFC 2183",
            dependencies: [
                .product(name: "ASCII", package: "swift-ascii"),
                .product(name: "RFC 2045", package: "swift-rfc-2045"),
                .product(name: "RFC 5322", package: "swift-rfc-5322"),
                .product(name: "Binary Primitives", package: "swift-binary-primitives"),
            ]
        ),
        .testTarget(
            name: "RFC 2183".tests,
            dependencies: ["RFC 2183"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
    var foundation: Self { self + " Foundation" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings =
        existing + [
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
        ]
}
