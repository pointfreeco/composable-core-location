import CoreLocation

/// A value type wrapper for `CLHeading`. This type is necessary so that we can do equality checks
/// and write tests against its values.
public struct Heading: Hashable, Sendable {
  public var headingAccuracy: CLLocationDirection
  public var magneticHeading: CLLocationDirection
  public var timestamp: Date
  public var trueHeading: CLLocationDirection
  public var x: CLHeadingComponentValue
  public var y: CLHeadingComponentValue
  public var z: CLHeadingComponentValue

  @available(iOS 3, macCatalyst 13, watchOS 2, *)
  @available(macOS, unavailable)
  @available(tvOS, unavailable)
  public init(rawValue: CLHeading) {
    self.headingAccuracy = rawValue.headingAccuracy
    self.magneticHeading = rawValue.magneticHeading
    self.timestamp = rawValue.timestamp
    self.trueHeading = rawValue.trueHeading
    self.x = rawValue.x
    self.y = rawValue.y
    self.z = rawValue.z
  }

  public init(
    headingAccuracy: CLLocationDirection,
    magneticHeading: CLLocationDirection,
    timestamp: Date,
    trueHeading: CLLocationDirection,
    x: CLHeadingComponentValue,
    y: CLHeadingComponentValue,
    z: CLHeadingComponentValue
  ) {
    self.headingAccuracy = headingAccuracy
    self.magneticHeading = magneticHeading
    self.timestamp = timestamp
    self.trueHeading = trueHeading
    self.x = x
    self.y = y
    self.z = z
  }
}
