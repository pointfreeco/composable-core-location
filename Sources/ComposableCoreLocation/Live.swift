import Combine
import ComposableArchitecture
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
    let manager = CLLocationManager()

    let delegate = Effect<Action, Never>.run { subscriber in
      let delegate = LocationManagerDelegate(subscriber)
      manager.delegate = delegate

      return AnyCancellable {
        _ = delegate
      }
    }
    .share()
    .eraseToEffect()

    return Self(
      accuracyAuthorization: {
        #if (compiler(>=5.3) && !(os(macOS) || targetEnvironment(macCatalyst))) || compiler(>=5.3.1)
          if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, macCatalyst 14.0, *) {
            return AccuracyAuthorization(manager.accuracyAuthorization)
          }
        #endif
        return nil
      },
      authorizationStatus: {
        #if (compiler(>=5.3) && !(os(macOS) || targetEnvironment(macCatalyst))) || compiler(>=5.3.1)
          if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, macCatalyst 14.0, *) {
            return manager.authorizationStatus
          }
        #endif
        return CLLocationManager.authorizationStatus()
      },
      delegate: { delegate },
      dismissHeadingCalibrationDisplay: {
        .fireAndForget {
          #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
            manager.dismissHeadingCalibrationDisplay()
          #endif
        }
      },
      heading: {
        #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
          return manager.heading.map(Heading.init(rawValue:))
        #else
          return nil
        #endif
      },
      headingAvailable: {
        #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
          return CLLocationManager.headingAvailable()
        #else
          return false
        #endif
      },
      isRangingAvailable: {
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          return CLLocationManager.isRangingAvailable()
        #else
          return false
        #endif
      },
      location: { manager.location.map(Location.init(rawValue:)) },
      locationServicesEnabled: CLLocationManager.locationServicesEnabled,
      maximumRegionMonitoringDistance: {
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          return manager.maximumRegionMonitoringDistance
        #else
          return CLLocationDistanceMax
        #endif
      },
      monitoredRegions: {
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          return Set(manager.monitoredRegions.map(Region.init(rawValue:)))
        #else
          return []
        #endif
      },
      requestAlwaysAuthorization: {
        .fireAndForget {
          #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
            manager.requestAlwaysAuthorization()
          #endif
        }
      },
      requestLocation: {
        .fireAndForget { manager.requestLocation() }
      },
      requestWhenInUseAuthorization: {
        .fireAndForget {
          #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
            manager.requestWhenInUseAuthorization()
          #endif
        }
      },
      requestTemporaryFullAccuracyAuthorization: { purposeKey in
        .run { subscriber in
          #if (compiler(>=5.3) && !(os(macOS) || targetEnvironment(macCatalyst))) || compiler(>=5.3.1)
            if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, macOS 11.0, macCatalyst 14.0, *) {
              manager.requestTemporaryFullAccuracyAuthorization(
                withPurposeKey: purposeKey
              ) { error in
                subscriber.send(completion: error.map { .failure(.init($0)) } ?? .finished)
              }
            } else {
              subscriber.send(completion: .finished)
            }
          #else
            subscriber.send(completion: .finished)
          #endif
          return AnyCancellable {}
        }
      },
      set: { properties in
        .fireAndForget {
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
        }
      },
      significantLocationChangeMonitoringAvailable: {
        #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
          return CLLocationManager.significantLocationChangeMonitoringAvailable()
        #else
          return false
        #endif
      },
      startMonitoringForRegion: { region in
        .fireAndForget {
          #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
            manager.startMonitoring(for: region.rawValue!)
          #endif
        }
      },
      startMonitoringSignificantLocationChanges: {
        .fireAndForget {
          #if os(iOS) || targetEnvironment(macCatalyst)
            manager.startMonitoringSignificantLocationChanges()
          #endif
        }
      },
      startMonitoringVisits: {
        .fireAndForget {
          #if os(iOS) || targetEnvironment(macCatalyst)
            manager.startMonitoringVisits()
          #endif
        }
      },
      startUpdatingHeading: {
        .fireAndForget {
          #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
            manager.startUpdatingHeading()
          #endif
        }
      },
      startUpdatingLocation: {
        .fireAndForget {
          #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
            manager.startUpdatingLocation()
          #endif
        }
      },
      stopMonitoringForRegion: { region in
        .fireAndForget {
          #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
            manager.stopMonitoring(for: region.rawValue!)
          #endif
        }
      },
      stopMonitoringSignificantLocationChanges: {
        .fireAndForget {
          #if os(iOS) || targetEnvironment(macCatalyst)
            manager.stopMonitoringSignificantLocationChanges()
          #endif
        }
      },
      stopMonitoringVisits: {
        .fireAndForget {
          #if os(iOS) || targetEnvironment(macCatalyst)
            manager.stopMonitoringVisits()
          #endif
        }
      },
      stopUpdatingHeading: {
        .fireAndForget {
          #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
            manager.stopUpdatingHeading()
          #endif
        }
      },
      stopUpdatingLocation: {
        .fireAndForget {
          #if os(iOS) || os(macOS) || os(watchOS) || targetEnvironment(macCatalyst)
            manager.stopUpdatingLocation()
          #endif
        }
      }
    )
  }
}

private class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
  let subscriber: Effect<LocationManager.Action, Never>.Subscriber

  init(_ subscriber: Effect<LocationManager.Action, Never>.Subscriber) {
    self.subscriber = subscriber
  }

  func locationManager(
    _ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus
  ) {
    self.subscriber.send(.didChangeAuthorization(status))
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    self.subscriber.send(.didFailWithError(LocationManager.Error(error)))
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    self.subscriber.send(.didUpdateLocations(locations.map(Location.init(rawValue:))))
  }

  #if os(macOS)
    func locationManager(
      _ manager: CLLocationManager, didUpdateTo newLocation: CLLocation,
      from oldLocation: CLLocation
    ) {
      self.subscriber.send(
        .didUpdateTo(
          newLocation: Location(rawValue: newLocation),
          oldLocation: Location(rawValue: oldLocation)
        )
      )
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?
    ) {
      self.subscriber.send(
        .didFinishDeferredUpdatesWithError(error.map(LocationManager.Error.init))
      )
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
      self.subscriber.send(.didPauseLocationUpdates)
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
      self.subscriber.send(.didResumeLocationUpdates)
    }
  #endif

  #if os(iOS) || os(watchOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
      self.subscriber.send(.didUpdateHeading(newHeading: Heading(rawValue: newHeading)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
      self.subscriber.send(.didEnterRegion(Region(rawValue: region)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
      self.subscriber.send(.didExitRegion(Region(rawValue: region)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion
    ) {
      self.subscriber.send(.didDetermineState(state, region: Region(rawValue: region)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error
    ) {
      self.subscriber.send(
        .monitoringDidFail(
          region: region.map(Region.init(rawValue:)), error: LocationManager.Error(error)))
    }
  #endif

  #if os(iOS) || os(macOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
      self.subscriber.send(.didStartMonitoring(region: Region(rawValue: region)))
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, didRange beacons: [CLBeacon],
      satisfying beaconConstraint: CLBeaconIdentityConstraint
    ) {
      self.subscriber.send(
        .didRangeBeacons(
          beacons.map(Beacon.init(rawValue:)), satisfyingConstraint: beaconConstraint
        )
      )
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManager(
      _ manager: CLLocationManager, didFailRangingFor beaconConstraint: CLBeaconIdentityConstraint,
      error: Error
    ) {
      self.subscriber.send(
        .didFailRanging(beaconConstraint: beaconConstraint, error: LocationManager.Error(error))
      )
    }
  #endif

  #if os(iOS) || targetEnvironment(macCatalyst)
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
      self.subscriber.send(.didVisit(Visit(visit: visit)))
    }
  #endif
}
