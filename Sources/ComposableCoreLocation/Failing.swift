import Combine
import CoreLocation
import IssueReporting

extension LocationManager {
  /// The failing implementation of the ``LocationManager`` interface. By default this
  /// implementation stubs all of its endpoints as functions that immediately call `reportIssue`.
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
  /// manager.delegate = { locationManagerSubject.eraseToEffect() }
  /// manager.locationServicesEnabled = { true }
  /// manager.requestLocation = {
  ///   .fireAndForget { locationManagerSubject.send(.didUpdateLocations([mockLocation])) }
  /// }
  /// ```
  public static let failing = Self(
    accuracyAuthorization: {
      reportIssue("A failing endpoint was accessed: 'LocationManager.accuracyAuthorization'")
      return nil
    },
    authorizationStatus: {
      reportIssue("A failing endpoint was accessed: 'LocationManager.authorizationStatus'")
      return .notDetermined
    },
    delegate: { .unimplemented("LocationManager.delegate") },
    dismissHeadingCalibrationDisplay: {
      .unimplemented("LocationManager.dismissHeadingCalibrationDisplay")
    },
    heading: {
      reportIssue("A failing endpoint was accessed: 'LocationManager.heading'")
      return nil
    },
    headingAvailable: {
      reportIssue("A failing endpoint was accessed: 'LocationManager.headingAvailable'")
      return false
    },
    isRangingAvailable: {
      reportIssue("A failing endpoint was accessed: 'LocationManager.isRangingAvailable'")
      return false
    },
    location: {
      reportIssue("A failing endpoint was accessed: 'LocationManager.location'")
      return nil
    },
    locationServicesEnabled: {
      reportIssue("A failing endpoint was accessed: 'LocationManager.locationServicesEnabled'")
      return false
    },
    maximumRegionMonitoringDistance: {
      reportIssue("A failing endpoint was accessed: 'LocationManager.maximumRegionMonitoringDistance'")
      return CLLocationDistanceMax
    },
    monitoredRegions: {
      reportIssue("A failing endpoint was accessed: 'LocationManager.monitoredRegions'")
      return []
    },
    requestAlwaysAuthorization: { .unimplemented("LocationManager.requestAlwaysAuthorization") },
    requestLocation: { .unimplemented("LocationManager.requestLocation") },
    requestWhenInUseAuthorization: {
      .unimplemented("LocationManager.requestWhenInUseAuthorization")
    },
    requestTemporaryFullAccuracyAuthorization: { _ in
      .unimplemented("LocationManager.requestTemporaryFullAccuracyAuthorization")
    },
    set: { _ in .unimplemented("LocationManager.set") },
    significantLocationChangeMonitoringAvailable: {
      reportIssue()
      return false
    },
    startMonitoringForRegion: { _ in .unimplemented("LocationManager.startMonitoringForRegion") },
    startMonitoringSignificantLocationChanges: {
      .unimplemented("LocationManager.startMonitoringSignificantLocationChanges")
    },
    startMonitoringVisits: { .unimplemented("LocationManager.startMonitoringVisits") },
    startUpdatingHeading: { .unimplemented("LocationManager.startUpdatingHeading") },
    startUpdatingLocation: { .unimplemented("LocationManager.startUpdatingLocation") },
    stopMonitoringForRegion: { _ in .unimplemented("LocationManager.stopMonitoringForRegion") },
    stopMonitoringSignificantLocationChanges: {
      .unimplemented("LocationManager.stopMonitoringSignificantLocationChanges")
    },
    stopMonitoringVisits: { .unimplemented("LocationManager.stopMonitoringVisits") },
    stopUpdatingHeading: { .unimplemented("LocationManager.stopUpdatingHeading") },
    stopUpdatingLocation: { .unimplemented("LocationManager.stopUpdatingLocation") }
  )
}
