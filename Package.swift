// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "composable-core-location",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(
      name: "ComposableCoreLocation",
      targets: ["ComposableCoreLocation"]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/xctest-dynamic-overlay",
      "0.9.0"..<"2.0.0"
    ),
  ],
  targets: [
    .target(
      name: "ComposableCoreLocation",
      dependencies: [
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ]
    ),
    .testTarget(
      name: "ComposableCoreLocationTests",
      dependencies: ["ComposableCoreLocation"]
    ),
  ]
)
