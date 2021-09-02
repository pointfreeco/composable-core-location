import ComposableArchitecture
import CoreLocation
import XCTestDynamicOverlay

extension LocationManager {
  /// The failing implementation of the ``LocationManager`` interface. By default this
  /// implementation stubs all of its endpoints as functions that immediately call `XCTFail`.
  ///
  /// This allows you to test an even deeper property of your features: that they use only the
  /// location manager endpoints that you specify and nothing else. This can be useful as a
  /// measurement of just how complex a particular test is. Tests that need to stub many endpoints
  /// are in some sense more complicated than tests that only need to stub a few endpoints. It's not
  /// necessarily a bad thing to stub many endpoints. Sometimes it's needed.
  ///
  /// As an example, to create a failing manager that simulates a location manager that has already
  /// authorized access to location, and when a location is requested it immediately responds
  /// with a mock location we can do something like this:
  ///
  /// ```swift
  /// // Send actions to this subject to simulate the location manager's delegate methods
  /// // being called.
  /// let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
  ///
  /// // The mock location we want the manager to say we are located at
  /// let mockLocation = Location(
  ///   coordinate: CLLocationCoordinate2D(latitude: 40.6501, longitude: -73.94958),
  ///   // A whole bunch of other properties have been omitted.
  /// )
  ///
  /// var manager = LocationManager.failing
  ///
  /// // Override any CLLocationManager endpoints your test invokes:
  /// manager.authorizationStatus = { .authorizedAlways }
  /// manager.authorizationStatus.create = { _ in locationManagerSubject.eraseToEffect() }
  /// manager.locationServicesEnabled = { true }
  /// manager.requestLocation = { _ in
  ///   .fireAndForget { locationManagerSubject.send(.didUpdateLocations([mockLocation])) }
  /// }
  /// ```
  public static let failing = Self(
    accuracyAuthorization: { _ in
      XCTFail("A failing endpoint was accessed: 'LocationManager.accuracyAuthorization'")
      return nil
    },
    authorizationStatus: {
      XCTFail("A failing endpoint was accessed: 'LocationManager.authorizationStatus'")
      return .notDetermined
    },
    create: { _ in .failing("LocationManager.create") },
    destroy: { _ in .failing("LocationManager.destroy") },
    dismissHeadingCalibrationDisplay: { _ in
      .failing("LocationManager.dismissHeadingCalibrationDisplay")
    },
    heading: { _ in
      XCTFail("A failing endpoint was accessed: 'LocationManager.heading'")
      return nil
    },
    headingAvailable: {
      XCTFail("A failing endpoint was accessed: 'LocationManager.headingAvailable'")
      return false
    },
    isRangingAvailable: {
      XCTFail("A failing endpoint was accessed: 'LocationManager.isRangingAvailable'")
      return false
    },
    location: { _ in
      XCTFail("A failing endpoint was accessed: 'LocationManager.location'")
      return nil
    },
    locationServicesEnabled: {
      XCTFail("A failing endpoint was accessed: 'LocationManager.locationServicesEnabled'")
      return false
    },
    maximumRegionMonitoringDistance: { _ in
      XCTFail("A failing endpoint was accessed: 'LocationManager.maximumRegionMonitoringDistance'")
      return CLLocationDistanceMax
    },
    monitoredRegions: { _ in
      XCTFail("A failing endpoint was accessed: 'LocationManager.monitoredRegions'")
      return []
    },
    requestAlwaysAuthorization: { _ in .failing("LocationManager.requestAlwaysAuthorization") },
    requestLocation: { _ in .failing("LocationManager.requestLocation") },
    requestWhenInUseAuthorization: { _ in
      .failing("LocationManager.requestWhenInUseAuthorization")
    },
    requestTemporaryFullAccuracyAuthorization: { _, _ in
      .failing("LocationManager.requestTemporaryFullAccuracyAuthorization")
    },
    set: { _, _ in .failing("LocationManager.set") },
    significantLocationChangeMonitoringAvailable: {
      XCTFail()
      return false
    },
    startMonitoringForRegion: { _, _ in .failing("LocationManager.startMonitoringForRegion") },
    startMonitoringSignificantLocationChanges: { _ in
      .failing("LocationManager.startMonitoringSignificantLocationChanges")
    },
    startMonitoringVisits: { _ in .failing("LocationManager.startMonitoringVisits") },
    startUpdatingHeading: { _ in .failing("LocationManager.startUpdatingHeading") },
    startUpdatingLocation: { _ in .failing("LocationManager.startUpdatingLocation") },
    stopMonitoringForRegion: { _, _ in .failing("LocationManager.stopMonitoringForRegion") },
    stopMonitoringSignificantLocationChanges: { _ in
      .failing("LocationManager.stopMonitoringSignificantLocationChanges")
    },
    stopMonitoringVisits: { _ in .failing("LocationManager.stopMonitoringVisits") },
    stopUpdatingHeading: { _ in .failing("LocationManager.stopUpdatingHeading") },
    stopUpdatingLocation: { _ in .failing("LocationManager.stopUpdatingLocation") }
  )
}
