// swift-tools-version: 5.9

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
    .package(url: "https://github.com/jacobcxdev/combine-schedulers", branch: "flote/service-app"),
    .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.3.0"),
    .package(url: "https://github.com/jacobcxdev/swift-custom-dump", from: "1.0.0"),
    .package(url: "https://github.com/jacobcxdev/swift-dependencies", branch: "flote/service-app"),
    .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "1.0.0"),
    .package(url: "https://github.com/jacobcxdev/swift-perception", branch: "flote/service-app"),
    .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", from: "1.4.3"),
    .package(url: "https://github.com/swiftlang/swift-docc-plugin", from: "1.0.0"),
    .package(url: "https://github.com/OpenCombine/OpenCombine.git", from: "0.14.0"),
    .package(url: "https://source.skip.tools/skip-fuse.git", from: "1.0.0"),
    .package(url: "https://source.skip.tools/skip-fuse-ui.git", from: "1.0.0"),
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
    .target(
      name: "Sharing1",
      path: "Sources/VersionMarkerModules/Sharing1"
    ),
    .target(
      name: "Sharing2",
      path: "Sources/VersionMarkerModules/Sharing2"
    ),
  ]
)
