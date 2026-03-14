// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "swift-sharing",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(
      name: "Sharing",
      targets: ["Sharing"]
    )
  ],
  dependencies: [
    .package(path: "../combine-schedulers"),
    .package(path: "../swift-concurrency-extras"),
    .package(path: "../swift-custom-dump"),
    .package(path: "../swift-dependencies"),
    .package(path: "../swift-identified-collections"),
    .package(path: "../swift-perception"),
    .package(path: "../xctest-dynamic-overlay"),
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.0.0"),
    .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.14.0"),
    .package(path: "../skip-fuse"),
    .package(path: "../skip-fuse-ui"),
  ],
  targets: [
    .target(
      name: "Sharing",
      dependencies: [
        "Sharing1",
        "Sharing2",
        .product(name: "CombineSchedulers", package: "combine-schedulers"),
        .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
        .product(name: "IssueReporting", package: "xctest-dynamic-overlay"),
        .product(name: "PerceptionCore", package: "swift-perception"),
        .product(name: "OpenCombineShim", package: "OpenCombine", condition: .when(platforms: [.linux, .android])),
        .product(name: "SkipFuse", package: "skip-fuse", condition: .when(platforms: [.android])),
        .product(name: "SkipFuseUI", package: "skip-fuse-ui", condition: .when(platforms: [.android])),
      ],
      resources: [
        .process("PrivacyInfo.xcprivacy")
      ]
    ),
    .testTarget(
      name: "SharingTests",
      dependencies: [
        "Sharing",
        .product(name: "DependenciesTestSupport", package: "swift-dependencies"),
      ],
      exclude: ["Sharing.xctestplan"]
    ),
    .target(
      name: "Sharing1",
      path: "Sources/VersionMarkerModules/Sharing1"
    ),
    .target(
      name: "Sharing2",
      path: "Sources/VersionMarkerModules/Sharing2"
    ),
  ],
  swiftLanguageModes: [.v6]
)
