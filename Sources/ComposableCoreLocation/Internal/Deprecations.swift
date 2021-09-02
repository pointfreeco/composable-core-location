// NB: Deprecated after 0.1.0:

#if DEBUG
  extension LocationManager {
    @available(
      *, deprecated,
      message:
        "Use 'Effect.cancellable' and 'Effect.cancel' to manage the lifecycle of 'LocationManager.delegate'"
    )
    public func create(id: AnyHashable) -> Effect<Action, Never> {
      self.delegate().cancellable(id: id)
    }

    @available(
      *, deprecated,
      message:
        "Use 'Effect.cancellable' and 'Effect.cancel' to manage the lifecycle of 'LocationManager.delegate'"
    )
    public func destroy(id: AnyHashable) -> Effect<Never, Never> {
      .cancel(id: id)
    }

    @available(*, unavailable, message: "Use 'LocationManager.failing', instead")
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
      requestTemporaryFullAccuracyAuthorization: @escaping (AnyHashable, String) -> Effect<
        Never, Never
      > = { _, _ in
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
      fatalError()
    }
  }

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
#endif
