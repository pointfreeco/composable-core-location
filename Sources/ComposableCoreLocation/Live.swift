import ConcurrencyExtras
import CoreLocation

extension LocationManager {
  /// The live implementation of the `LocationManager` interface. This implementation is capable of
  /// creating real `CLLocationManager` instances, listening to its delegate methods, and invoking
  /// its methods. You will typically use this when building for the simulator or device:
  ///
  /// ```swift
  /// let store = Store(
  ///   initialState: AppState(),
  ///   reducer: appReducer,
  ///   environment: AppEnvironment(
  ///     locationManager: LocationManager.live
  ///   )
  /// )
  /// ```
  public static var live: Self {
    let task = Task<LocationManagerSendableBox, Never> { @MainActor in
      let manager = CLLocationManager()
      let delegate = LocationManagerDelegate()
      manager.delegate = delegate
      return .init(manager: manager, delegate: delegate)
    }

    return Self(
      accuracyAuthorization: { @MainActor in
        #if (compiler(>=5.3) && !(os(macOS) || targetEnvironment(macCatalyst))) || compiler(>=5.3.1)
          if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, macCatalyst 14.0, *) {
            return await AccuracyAuthorization(task.value.manager.accuracyAuthorization)
          }
        #endif
        return nil
      },
      authorizationStatus: { @MainActor in
        #if (compiler(>=5.3) && !(os(macOS) || targetEnvironment(macCatalyst))) || compiler(>=5.3.1)
          if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, macCatalyst 14.0, *) {
            return await task.value.manager.authorizationStatus
          }
        #endif
        return CLLocationManager.authorizationStatus()
      },
      delegate: { @MainActor in
        let delegate = await task.value.delegate
        return AsyncStream { delegate.registerContinuation($0) }
      },
      dismissHeadingCalibrationDisplay: { @MainActor in
        #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
          await task.value.manager.dismissHeadingCalibrationDisplay()
        #endif
      },
      heading: { @MainActor in
        #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
          return await task.value.manager.heading.map(Heading.init(rawValue:))
        #else
          return nil
        #endif
      },
      headingAvailable: { @MainActor in
        #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
          return CLLocationManager.headingAvailable()
        #else
          return false
        #endif
      },
      isRangingAvailable: { @MainActor in
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          return CLLocationManager.isRangingAvailable()
        #else
          return false
        #endif
      },
      location: { @MainActor in await task.value.manager.location.map(Location.init(rawValue:)) },
      locationServicesEnabled: { CLLocationManager.locationServicesEnabled() },
      maximumRegionMonitoringDistance: { @MainActor in
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          return await task.value.manager.maximumRegionMonitoringDistance
        #else
          return CLLocationDistanceMax
        #endif
      },
      monitoredRegions: { @MainActor in
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          return await Set(task.value.manager.monitoredRegions.map(Region.init(rawValue:)))
        #else
          return []
        #endif
      },
      requestAlwaysAuthorization: { @MainActor in
        #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
          await task.value.manager.requestAlwaysAuthorization()
        #endif
      },
      requestLocation: { @MainActor in
        await task.value.manager.requestLocation()
      },
      requestWhenInUseAuthorization: { @MainActor in
        #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
          await task.value.manager.requestWhenInUseAuthorization()
        #endif
      },
      requestTemporaryFullAccuracyAuthorization: { @MainActor purposeKey in
        #if (compiler(>=5.3) && !(os(macOS) || targetEnvironment(macCatalyst))) || compiler(>=5.3.1)
          if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, macCatalyst 14.0, *) {
            try await task.value.manager.requestTemporaryFullAccuracyAuthorization(
              withPurposeKey: purposeKey)
          }
        #endif
      },
      set: { @MainActor properties in
        let manager = await task.value.manager

        #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
          if let activityType = properties.activityType {
            manager.activityType = activityType
          }
          if let allowsBackgroundLocationUpdates = properties.allowsBackgroundLocationUpdates {
            manager.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates
          }
        #endif
        #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS) || targetEnvironment(macCatalyst)
          if let desiredAccuracy = properties.desiredAccuracy {
            manager.desiredAccuracy = desiredAccuracy
          }
          if let distanceFilter = properties.distanceFilter {
            manager.distanceFilter = distanceFilter
          }
        #endif
        #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
          if let headingFilter = properties.headingFilter {
            manager.headingFilter = headingFilter
          }
          if let headingOrientation = properties.headingOrientation {
            manager.headingOrientation = headingOrientation
          }
        #endif
        #if os(iOS) || targetEnvironment(macCatalyst)
          if let pausesLocationUpdatesAutomatically = properties
            .pausesLocationUpdatesAutomatically
          {
            manager.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically
          }
          if let showsBackgroundLocationIndicator = properties.showsBackgroundLocationIndicator {
            manager.showsBackgroundLocationIndicator = showsBackgroundLocationIndicator
          }
        #endif
      },
      significantLocationChangeMonitoringAvailable: { @MainActor in
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          return CLLocationManager.significantLocationChangeMonitoringAvailable()
        #else
          return false
        #endif
      },
      startMonitoringForRegion: { @MainActor region in
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          await task.value.manager.startMonitoring(for: region.rawValue!)
        #endif
      },
      startMonitoringSignificantLocationChanges: { @MainActor in
        #if os(iOS) || targetEnvironment(macCatalyst)
          await task.value.manager.startMonitoringSignificantLocationChanges()
        #endif
      },
      startMonitoringVisits: { @MainActor in
        #if os(iOS) || targetEnvironment(macCatalyst)
          await task.value.manager.startMonitoringVisits()
        #endif
      },
      startUpdatingHeading: { @MainActor in
        #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
          await task.value.manager.startUpdatingHeading()
        #endif
      },
      startUpdatingLocation: { @MainActor in
        #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
          await task.value.manager.startUpdatingLocation()
        #endif
      },
      stopMonitoringForRegion: { @MainActor region in
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          await task.value.manager.stopMonitoring(for: region.rawValue!)
        #endif
      },
      stopMonitoringSignificantLocationChanges: { @MainActor in
        #if os(iOS) || targetEnvironment(macCatalyst)
          await task.value.manager.stopMonitoringSignificantLocationChanges()
        #endif
      },
      stopMonitoringVisits: { @MainActor in
        #if os(iOS) || targetEnvironment(macCatalyst)
          await task.value.manager.stopMonitoringVisits()
        #endif
      },
      stopUpdatingHeading: { @MainActor in
        #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
          await task.value.manager.stopUpdatingHeading()
        #endif
      },
      stopUpdatingLocation: { @MainActor in
        #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
          await task.value.manager.stopUpdatingLocation()
        #endif
      }
    )
  }
}

private struct LocationManagerSendableBox: Sendable {
  @UncheckedSendable var manager: CLLocationManager
  var delegate: LocationManagerDelegate
}

private final class LocationManagerDelegate: NSObject, CLLocationManagerDelegate, Sendable {
  let continuations: ActorIsolated<[UUID: AsyncStream<LocationManager.Action>.Continuation]>

  override init() {
    self.continuations = .init([:])
    super.init()
  }

  func registerContinuation(_ continuation: AsyncStream<LocationManager.Action>.Continuation) {
    Task { [continuations] in
      await continuations.withValue {
        let id = UUID()
        $0[id] = continuation
        continuation.onTermination = { [weak self] _ in self?.unregisterContinuation(withID: id) }
      }
    }
  }

  private func unregisterContinuation(withID id: UUID) {
    Task { [continuations] in await continuations.withValue { $0.removeValue(forKey: id) } }
  }

  private func send(_ action: LocationManager.Action) {
    Task { [continuations] in
      await continuations.withValue { $0.values.forEach { $0.yield(action) } }
    }
  }

  func locationManager(
    _ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus
  ) {
    send(.didChangeAuthorization(status))
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    send(.didFailWithError(LocationManager.Error(error)))
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    send(.didUpdateLocations(locations.map(Location.init(rawValue:))))
  }

  #if os(macOS)
    func locationManager(
      _ manager: CLLocationManager, didUpdateTo newLocation: CLLocation,
      from oldLocation: CLLocation
    ) {
      send(
        .didUpdateTo(
          newLocation: Location(rawValue: newLocation), oldLocation: Location(rawValue: oldLocation)
        ))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?
    ) {
      send(
        .didFinishDeferredUpdatesWithError(error.map(LocationManager.Error.init))
      )
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
      send(.didPauseLocationUpdates)
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
      send(.didResumeLocationUpdates)
    }
  #endif

  #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
      send(.didUpdateHeading(newHeading: Heading(rawValue: newHeading)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
      send(.didEnterRegion(Region(rawValue: region)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
      send(.didExitRegion(Region(rawValue: region)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion
    ) {
      send(.didDetermineState(state, region: Region(rawValue: region)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error
    ) {
      send(
        .monitoringDidFail(
          region: region.map(Region.init(rawValue:)), error: LocationManager.Error(error)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
      send(.didStartMonitoring(region: Region(rawValue: region)))
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, didRange beacons: [CLBeacon],
      satisfying beaconConstraint: CLBeaconIdentityConstraint
    ) {
      send(
        .didRangeBeacons(
          beacons.map(Beacon.init(rawValue:)),
          satisfyingConstraint: BeaconConstraint(rawValue: beaconConstraint)
        )
      )
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint,
      error: Error
    ) {
      send(
        .didFailRanging(
          beaconConstraint: BeaconConstraint(rawValue: beaconConstraint),
          error: LocationManager.Error(error))
      )
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
      send(.didVisit(Visit(visit: visit)))
    }
  #endif
}
