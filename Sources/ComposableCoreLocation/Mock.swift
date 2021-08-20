#if DEBUG
  import CoreLocation
  import ComposableArchitecture

  extension LocationManager {
    /// The mock implementation of the `LocationManager` interface. By default this implementation
    /// stubs all of its endpoints as functions that immediately `fatalError`. So, to construct a
    /// mock you will invoke the `.unimplemented` static method, and provide implementations for all
    /// of the endpoints that you expect your test to need access to.
    ///
    /// This allows you to test an even deeper property of your features: that they use only the
    /// location manager endpoints that you specify and nothing else. This can be useful as a
    /// measurement of just how complex a particular test is. Tests that need to stub many endpoints
    /// are in some sense more complicated than tests that only need to stub a few endpoints. It's
    /// not necessarily a bad thing to stub many endpoints. Sometimes it's needed.
    ///
    /// As an example, to create a mock manager that simulates a location manager that has already
    /// authorized access to location, and when a location is requested it immediately responds
    /// with a mock location we can do something like this:
    ///
    ///     // Send actions to this subject to simulate the location manager's delegate methods
    ///     // being called.
    ///     let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
    ///
    ///     // The mock location we want the manager to say we are located at
    ///     let mockLocation = Location(
    ///       coordinate: CLLocationCoordinate2D(latitude: 40.6501, longitude: -73.94958),
    ///       // A whole bunch of other properties have been omitted.
    ///     )
    ///
    ///     let manager = LocationManager.unimplemented(
    ///       // Override any CLLocationManager endpoints your test invokes:
    ///
    ///       authorizationStatus: { .authorizedAlways },
    ///       create: { _ in locationManagerSubject.eraseToEffect() },
    ///       locationServicesEnabled: { true },
    ///       requestLocation: { _ in
    ///         .fireAndForget { locationManagerSubject.send(.didUpdateLocations([mockLocation])) }
    ///       }
    ///     )
    ///
    public static func unimplemented(
      accuracyAuthorization: @escaping (AnyHashable) -> AccuracyAuthorization? = { _ in
        _unimplemented("accuracyAuthorization")
      },
      authorizationStatus: @escaping () -> CLAuthorizationStatus = {
        _unimplemented("authorizationStatus")
      },
      create: @escaping (_ id: AnyHashable) -> Effect<Action, Never> = { _ in
        _unimplemented("create")
      },
      destroy: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in _unimplemented("destroy") },
      dismissHeadingCalibrationDisplay: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
        _unimplemented("dismissHeadingCalibrationDisplay")
      },
      heading: @escaping (AnyHashable) -> Heading? = { _ in _unimplemented("heading") },
      headingAvailable: @escaping () -> Bool = { _unimplemented("headingAvailable") },
      isRangingAvailable: @escaping () -> Bool = { _unimplemented("isRangingAvailable") },
      location: @escaping (AnyHashable) -> Location? = { _ in _unimplemented("location") },
      locationServicesEnabled: @escaping () -> Bool = { _unimplemented("locationServicesEnabled") },
      maximumRegionMonitoringDistance: @escaping (AnyHashable) -> CLLocationDistance = { _ in
        _unimplemented("maximumRegionMonitoringDistance")
      },
      monitoredRegions: @escaping (AnyHashable) -> Set<Region> = { _ in
        _unimplemented("monitoredRegions")
      },
      requestAlwaysAuthorization: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
        _unimplemented("requestAlwaysAuthorization")
      },
      requestLocation: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
        _unimplemented("requestLocation")
      },
      requestWhenInUseAuthorization: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
        _unimplemented("requestWhenInUseAuthorization")
      },
      requestTemporaryFullAccuracyAuthorization: @escaping (AnyHashable, String) -> Effect<Never, Never> = { _, _ in
        _unimplemented("requestTemporaryFullAccuracyAuthorization")
      },
      set: @escaping (_ id: AnyHashable, _ properties: Properties) -> Effect<Never, Never> = {
        _, _ in _unimplemented("set")
      },
      significantLocationChangeMonitoringAvailable: @escaping () -> Bool = {
        _unimplemented("significantLocationChangeMonitoringAvailable")
      },
      startMonitoringSignificantLocationChanges: @escaping (AnyHashable) -> Effect<Never, Never> = {
        _ in _unimplemented("startMonitoringSignificantLocationChanges")
      },
      startMonitoringForRegion: @escaping (AnyHashable, Region) -> Effect<Never, Never> = { _, _ in
        _unimplemented("startMonitoringForRegion")
      },
      startMonitoringVisits: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
        _unimplemented("startMonitoringVisits")
      },
      startUpdatingLocation: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
        _unimplemented("startUpdatingLocation")
      },
      stopMonitoringSignificantLocationChanges: @escaping (AnyHashable) -> Effect<Never, Never> = {
        _ in _unimplemented("stopMonitoringSignificantLocationChanges")
      },
      stopMonitoringForRegion: @escaping (AnyHashable, Region) -> Effect<Never, Never> = { _, _ in
        _unimplemented("stopMonitoringForRegion")
      },
      stopMonitoringVisits: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
        _unimplemented("stopMonitoringVisits")
      },
      startUpdatingHeading: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
        _unimplemented("startUpdatingHeading")
      },
      stopUpdatingHeading: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
        _unimplemented("stopUpdatingHeading")
      },
      stopUpdatingLocation: @escaping (AnyHashable) -> Effect<Never, Never> = { _ in
        _unimplemented("stopUpdatingLocation")
      }
    ) -> Self {
      Self(
        accuracyAuthorization: accuracyAuthorization,
        authorizationStatus: authorizationStatus,
        create: create,
        destroy: destroy,
        dismissHeadingCalibrationDisplay: dismissHeadingCalibrationDisplay,
        heading: heading,
        headingAvailable: headingAvailable,
        isRangingAvailable: isRangingAvailable,
        location: location,
        locationServicesEnabled: locationServicesEnabled,
        maximumRegionMonitoringDistance: maximumRegionMonitoringDistance,
        monitoredRegions: monitoredRegions,
        requestAlwaysAuthorization: requestAlwaysAuthorization,
        requestLocation: requestLocation,
        requestWhenInUseAuthorization: requestWhenInUseAuthorization,
        requestTemporaryFullAccuracyAuthorization: requestTemporaryFullAccuracyAuthorization,
        set: set,
        significantLocationChangeMonitoringAvailable: significantLocationChangeMonitoringAvailable,
        startMonitoringForRegion: startMonitoringForRegion,
        startMonitoringSignificantLocationChanges: startMonitoringSignificantLocationChanges,
        startMonitoringVisits: startMonitoringVisits,
        startUpdatingHeading: startUpdatingHeading,
        startUpdatingLocation: startUpdatingLocation,
        stopMonitoringForRegion: stopMonitoringForRegion,
        stopMonitoringSignificantLocationChanges: stopMonitoringSignificantLocationChanges,
        stopMonitoringVisits: stopMonitoringVisits,
        stopUpdatingHeading: stopUpdatingHeading,
        stopUpdatingLocation: stopUpdatingLocation
      )
    }
  }
#endif

public func _unimplemented(
  _ function: StaticString, file: StaticString = #file, line: UInt = #line
) -> Never {
  fatalError(
    """
    `\(function)` was called but is not implemented. Be sure to provide an implementation for
    this endpoint when creating the mock.
    """,
    file: file,
    line: line
  )
}
