// swift-tools-version:5.1

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
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.9.0")
  ],
  targets: [
    .target(
      name: "ComposableCoreLocation",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
      ]
    ),
    .testTarget(
      name: "ComposableCoreLocationTests",
      dependencies: ["ComposableCoreLocation"]
    ),
  ]
)
