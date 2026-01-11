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
        .package(path: "../swift-incits-4-1986"),
        .package(path: "../swift-rfc-2045"),
        .package(path: "../swift-rfc-5322"),
        .package(path: "../../swift-primitives/swift-binary-primitives"),
    ],
    targets: [
        .target(
            name: "RFC 2183",
            dependencies: [
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986"),
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
