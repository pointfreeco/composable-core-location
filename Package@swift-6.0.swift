// swift-tools-version:6.0

import PackageDescription

let package = Package(
  name: "core-location-client",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6),
  ],
  products: [
    .library(
      name: "CoreLocationClient",
      targets: ["CoreLocationClient"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.6.0"),
    .package(url: "https://github.com/pointfreeco/swift-concurrency-extras", from: "1.3.0"),
  ],
  targets: [
    .target(
      name: "CoreLocationClient",
      dependencies: [
        .product(name: "Dependencies", package: "swift-dependencies"),
        .product(name: "DependenciesMacros", package: "swift-dependencies"),
        .product(name: "ConcurrencyExtras", package: "swift-concurrency-extras"),
      ]
    ),
    .testTarget(
      name: "CoreLocationClientTests",
      dependencies: ["CoreLocationClient"]
    ),
  ]
)

for target in package.targets {
  target.swiftSettings = target.swiftSettings ?? []
  target.swiftSettings?.append(
    .unsafeFlags([
      "-Xfrontend", "-warn-concurrency",
      "-Xfrontend", "-enable-actor-data-race-checks",
    ])
  )
}
