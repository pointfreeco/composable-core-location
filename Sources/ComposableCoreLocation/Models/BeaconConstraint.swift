import ConcurrencyExtras
import CoreLocation

/// A value type wrapper for `CLBeaconIdentityConstraint`. This type is necessary to add `Sendable`
/// conformance to `LocationManager.Action`.
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct BeaconConstraint: Hashable, Sendable {
  @UncheckedSendable public private(set) var rawValue: CLBeaconIdentityConstraint

  public init(rawValue: CLBeaconIdentityConstraint) {
    self.rawValue = rawValue
  }

  public subscript<T>(dynamicMember keyPath: KeyPath<CLBeaconIdentityConstraint, T>) -> T {
    self.rawValue[keyPath: keyPath]
  }
}
