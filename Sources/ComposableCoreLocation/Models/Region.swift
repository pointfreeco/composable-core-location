import ConcurrencyExtras
import CoreLocation

/// A value type wrapper for `CLRegion`. This type is necessary so that we can do equality checks
/// and write tests against its values.
public struct Region: Hashable, Sendable {
  @UncheckedSendable public private(set) var rawValue: CLRegion?

  public var identifier: String
  public var notifyOnEntry: Bool
  public var notifyOnExit: Bool

  public init(rawValue: CLRegion) {
    self.rawValue = rawValue

    self.identifier = rawValue.identifier
    self.notifyOnEntry = rawValue.notifyOnEntry
    self.notifyOnExit = rawValue.notifyOnExit
  }

  public init(
    identifier: String,
    notifyOnEntry: Bool,
    notifyOnExit: Bool
  ) {
    self.rawValue = nil

    self.identifier = identifier
    self.notifyOnEntry = notifyOnEntry
    self.notifyOnExit = notifyOnExit
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.identifier == rhs.identifier
      && lhs.notifyOnEntry == rhs.notifyOnEntry
      && lhs.notifyOnExit == rhs.notifyOnExit
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(self.identifier)
    hasher.combine(self.notifyOnExit)
    hasher.combine(self.notifyOnEntry)
  }
}
