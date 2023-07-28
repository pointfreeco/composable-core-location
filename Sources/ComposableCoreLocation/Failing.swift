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
  /// manager.delegate = { locationManagerSubject.eraseToEffect() }
  /// manager.locationServicesEnabled = { true }
  /// manager.requestLocation = {
  ///   .fireAndForget { locationManagerSubject.send(.didUpdateLocations([mockLocation])) }
  /// }
  /// ```
  public static let failing = Self(
    accuracyAuthorization: XCTUnimplemented("LocationManager.accuracyAuthorization"),
    authorizationStatus: XCTUnimplemented("A failing endpoint was accessed: 'LocationManager.authorizationStatus'"),
    delegate: XCTUnimplemented("LocationManager.delegate"),
    dismissHeadingCalibrationDisplay: XCTUnimplemented("LocationManager.dismissHeadingCalibrationDisplay"),
    heading: XCTUnimplemented("A failing endpoint was accessed: 'LocationManager.heading'"),
    headingAvailable: XCTUnimplemented("LocationManager.headingAvailable"),
    isRangingAvailable: XCTUnimplemented("LocationManager.isRangingAvailable"),
    location: XCTUnimplemented("LocationManager.location"),
    locationServicesEnabled: XCTUnimplemented("LocationManager.locationServicesEnabled"),
    maximumRegionMonitoringDistance: XCTUnimplemented("LocationManager.maximumRegionMonitoringDistance"),
    monitoredRegions: XCTUnimplemented("LocationManager.monitoredRegions"),
    requestAlwaysAuthorization: XCTUnimplemented("LocationManager.requestAlwaysAuthorization"),
    requestLocation: XCTUnimplemented("LocationManager.requestLocation"),
    requestWhenInUseAuthorization: XCTUnimplemented("LocationManager.requestWhenInUseAuthorization"),
    requestTemporaryFullAccuracyAuthorization: XCTUnimplemented("LocationManager.requestTemporaryFullAccuracyAuthorization"),
    set: XCTUnimplemented("LocationManager.set"),
    significantLocationChangeMonitoringAvailable: XCTUnimplemented("LocationManager.significantLocationChangeMonitoringAvailable"),
    startMonitoringForRegion: XCTUnimplemented("LocationManager.startMonitoringForRegion"),
    startMonitoringSignificantLocationChanges: XCTUnimplemented("LocationManager.startMonitoringSignificantLocationChanges"),
    startMonitoringVisits: XCTUnimplemented("LocationManager.startMonitoringVisits"),
    startUpdatingHeading: XCTUnimplemented("LocationManager.startUpdatingHeading"),
    startUpdatingLocation: XCTUnimplemented("LocationManager.startUpdatingLocation"),
    stopMonitoringForRegion: XCTUnimplemented("LocationManager.stopMonitoringForRegion"),
    stopMonitoringSignificantLocationChanges: XCTUnimplemented("LocationManager.stopMonitoringSignificantLocationChanges"),
    stopMonitoringVisits: XCTUnimplemented("LocationManager.stopMonitoringVisits"),
    stopUpdatingHeading: XCTUnimplemented("LocationManager.stopUpdatingHeading"),
    stopUpdatingLocation: XCTUnimplemented("LocationManager.stopUpdatingLocation")
  )
}
