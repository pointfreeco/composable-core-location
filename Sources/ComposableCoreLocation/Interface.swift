import Combine
import ComposableArchitecture
import CoreLocation

/// A wrapper around Core Location's `CLLocationManager` that exposes its functionality through
/// effects and actions, making it easy to use with the Composable Architecture and easy to test.
///
/// To use it, one begins by adding an action to your domain that represents all of the actions the
/// manager can emit via the `CLLocationManagerDelegate` methods:
///
/// ```swift
/// import ComposableCoreLocation
///
/// enum AppAction {
///   case locationManager(LocationManager.Action)
///
///   // Your domain's other actions:
///   ...
/// }
/// ```
///
/// The `LocationManager.Action` enum holds a case for each delegate method of
/// `CLLocationManagerDelegate`, such as `didUpdateLocations`, `didEnterRegion`, `didUpdateHeading`,
/// and more.
///
/// Next we add a `LocationManager`, which is a wrapper around `CLLocationManager` that the library
/// provides, to the application's environment of dependencies:
///
/// ```swift
/// struct AppEnvironment {
///   var locationManager: LocationManager
///
///   // Your domain's other dependencies:
///   ...
/// }
/// ```
///
/// Then, we simultaneously subscribe to delegate actions and request authorization from our
/// application's reducer by returning an effect from an action to kick things off. One good choice
/// for such an action is the `onAppear` of your view.
///
/// ```swift
/// let appReducer = Reducer<AppState, AppAction, AppEnvironment> {
///   state, action, environment in
///
///   switch action {
///   case .onAppear:
///     return .merge(
///       environment.locationManager
///         .delegate()
///         .map(AppAction.locationManager),
///
///       environment.locationManager
///         .requestWhenInUseAuthorization()
///         .fireAndForget()
///     )
///
///   ...
///   }
/// }
/// ```
///
/// With that initial setup we will now get all of `CLLocationManagerDelegate`'s delegate methods
/// delivered to our reducer via actions. To handle a particular delegate action we can destructure
/// it inside the `.locationManager` case we added to our `AppAction`. For example, once we get
/// location authorization from the user we could request their current location:
///
/// ```swift
/// case .locationManager(.didChangeAuthorization(.authorizedAlways)),
///      .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):
///
///   return environment.locationManager
///     .requestLocation()
///     .fireAndForget()
/// ```
///
/// If the user denies location access we can show an alert telling them that we need access to be
/// able to do anything in the app:
///
/// ```swift
/// case .locationManager(.didChangeAuthorization(.denied)),
///      .locationManager(.didChangeAuthorization(.restricted)):
///
///   state.alert = """
///     Please give location access so that we can show you some cool stuff.
///     """
///   return .none
/// ```
///
/// Otherwise, we'll be notified of the user's location by handling the `.didUpdateLocations`
/// action:
///
/// ```swift
/// case let .locationManager(.didUpdateLocations(locations)):
///   // Do something cool with user's current location.
///   ...
/// ```
///
/// Once you have handled all the `CLLocationManagerDelegate` actions you care about, you can ignore
/// the rest:
///
/// ```swift
/// case .locationManager:
///   return .none
/// ```
///
/// And finally, when creating the `Store` to power your application you will supply the "live"
/// implementation of the `LocationManager`, which is an instance that holds onto a
/// `CLLocationManager` on the inside and interacts with it directly:
///
/// ```swift
/// let store = Store(
///   initialState: AppState(),
///   reducer: appReducer,
///   environment: AppEnvironment(
///     locationManager: .live,
///     // And your other dependencies...
///   )
/// )
/// ```
///
/// This is enough to implement a basic application that interacts with Core Location.
///
/// The true power of building your application and interfacing with Core Location in this way is
/// the ability to _test_ how your application interacts with Core Location. It starts by creating
/// a `TestStore` whose environment contains a ``failing`` version of the `LocationManager`. Then,
/// you can selectively override whichever endpoints your feature needs to supply deterministic
/// functionality.
///
/// For example, to test the flow of asking for location authorization, being denied, and showing an
/// alert, we need to override the `create` and `requestWhenInUseAuthorization` endpoints. The
/// `create` endpoint needs to return an effect that emits the delegate actions, which we can
/// control via a publish subject. And the `requestWhenInUseAuthorization` endpoint is a
/// fire-and-forget effect, but we can make assertions that it was called how we expect.
///
/// ```swift
/// let store = TestStore(
///   initialState: AppState(),
///   reducer: appReducer,
///   environment: AppEnvironment(
///     locationManager: .failing
///   )
/// )
///
/// var didRequestInUseAuthorization = false
/// let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()
///
/// store.environment.locationManager.create = { locationManagerSubject.eraseToEffect() }
/// store.environment.locationManager.requestWhenInUseAuthorization = {
///   .fireAndForget { didRequestInUseAuthorization = true }
/// }
/// ```
///
/// Then we can write an assertion that simulates a sequence of user steps and location manager
/// delegate actions, and we can assert against how state mutates and how effects are received. For
/// example, we can have the user come to the screen, deny the location authorization request, and
/// then assert that an effect was received which caused the alert to show:
///
/// ```swift
/// store.send(.onAppear)
///
/// // Simulate the user denying location access
/// locationManagerSubject.send(.didChangeAuthorization(.denied))
///
/// // We receive the authorization change delegate action from the effect
/// store.receive(.locationManager(.didChangeAuthorization(.denied))) {
///   $0.alert = """
///     Please give location access so that we can show you some cool stuff.
///     """
///
/// // Store assertions require all effects to be completed, so we complete
/// // the subject manually.
/// locationManagerSubject.send(completion: .finished)
/// ```
///
/// And this is only the tip of the iceberg. We can further test what happens when we are granted
/// authorization by the user and the request for their location returns a specific location that we
/// control, and even what happens when the request for their location fails. It is very easy to
/// write these tests, and we can test deep, subtle properties of our application.
///
public struct LocationManager {
  /// Actions that correspond to `CLLocationManagerDelegate` methods.
  ///
  /// See `CLLocationManagerDelegate` for more information.
  public enum Action: Equatable {
    case didChangeAuthorization(CLAuthorizationStatus)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didDetermineState(CLRegionState, region: Region)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didEnterRegion(Region)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didExitRegion(Region)

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didFailRanging(beaconConstraint: CLBeaconIdentityConstraint, error: Error)

    case didFailWithError(Error)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didFinishDeferredUpdatesWithError(Error?)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didPauseLocationUpdates

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didResumeLocationUpdates

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didStartMonitoring(region: Region)

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    case didUpdateHeading(newHeading: Heading)

    case didUpdateLocations([Location])

    @available(macCatalyst, deprecated: 13)
    @available(tvOS, unavailable)
    case didUpdateTo(newLocation: Location, oldLocation: Location)

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didVisit(Visit)

    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case monitoringDidFail(region: Region?, error: Error)

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case didRangeBeacons([Beacon], satisfyingConstraint: CLBeaconIdentityConstraint)
  }

  public struct Error: Swift.Error, Equatable {
    public let error: NSError

    public init(_ error: Swift.Error) {
      self.error = error as NSError
    }
  }

  public var accuracyAuthorization: () -> AccuracyAuthorization?

  public var authorizationStatus: () -> CLAuthorizationStatus

  public var delegate: () -> EffectPublisher<Action, Never>

  public var dismissHeadingCalibrationDisplay: () -> EffectPublisher<Never, Never>

  public var heading: () -> Heading?

  public var headingAvailable: () -> Bool

  public var isRangingAvailable: () -> Bool

  public var location: () -> Location?

  public var locationServicesEnabled: () -> Bool

  public var maximumRegionMonitoringDistance: () -> CLLocationDistance

  public var monitoredRegions: () -> Set<Region>

  public var requestAlwaysAuthorization: () -> EffectPublisher<Never, Never>

  public var requestLocation: () -> EffectPublisher<Never, Never>

  public var requestWhenInUseAuthorization: () -> EffectPublisher<Never, Never>

  public var requestTemporaryFullAccuracyAuthorization: (String) -> EffectPublisher<Never, Error>

  public var set: (Properties) -> EffectPublisher<Never, Never>

  public var significantLocationChangeMonitoringAvailable: () -> Bool

  public var startMonitoringForRegion: (Region) -> EffectPublisher<Never, Never>

  public var startMonitoringSignificantLocationChanges: () -> EffectPublisher<Never, Never>

  public var startMonitoringVisits: () -> EffectPublisher<Never, Never>

  public var startUpdatingHeading: () -> EffectPublisher<Never, Never>

  public var startUpdatingLocation: () -> EffectPublisher<Never, Never>

  public var stopMonitoringForRegion: (Region) -> EffectPublisher<Never, Never>

  public var stopMonitoringSignificantLocationChanges: () -> EffectPublisher<Never, Never>

  public var stopMonitoringVisits: () -> EffectPublisher<Never, Never>

  public var stopUpdatingHeading: () -> EffectPublisher<Never, Never>

  public var stopUpdatingLocation: () -> EffectPublisher<Never, Never>

  /// Updates the given properties of a uniquely identified `CLLocationManager`.
  public func set(
    activityType: CLActivityType? = nil,
    allowsBackgroundLocationUpdates: Bool? = nil,
    desiredAccuracy: CLLocationAccuracy? = nil,
    distanceFilter: CLLocationDistance? = nil,
    headingFilter: CLLocationDegrees? = nil,
    headingOrientation: CLDeviceOrientation? = nil,
    pausesLocationUpdatesAutomatically: Bool? = nil,
    showsBackgroundLocationIndicator: Bool? = nil
  ) -> EffectPublisher<Never, Never> {
    #if os(macOS) || os(tvOS) || os(watchOS)
      return .none
    #else
      return self.set(
        Properties(
          activityType: activityType,
          allowsBackgroundLocationUpdates: allowsBackgroundLocationUpdates,
          desiredAccuracy: desiredAccuracy,
          distanceFilter: distanceFilter,
          headingFilter: headingFilter,
          headingOrientation: headingOrientation,
          pausesLocationUpdatesAutomatically: pausesLocationUpdatesAutomatically,
          showsBackgroundLocationIndicator: showsBackgroundLocationIndicator
        )
      )
    #endif
  }
}

extension LocationManager {
  public struct Properties: Equatable {
    var activityType: CLActivityType? = nil

    var allowsBackgroundLocationUpdates: Bool? = nil

    var desiredAccuracy: CLLocationAccuracy? = nil

    var distanceFilter: CLLocationDistance? = nil

    var headingFilter: CLLocationDegrees? = nil

    var headingOrientation: CLDeviceOrientation? = nil

    var pausesLocationUpdatesAutomatically: Bool? = nil

    var showsBackgroundLocationIndicator: Bool? = nil

    public static func == (lhs: Self, rhs: Self) -> Bool {
      var isEqual = true
      #if os(iOS) || targetEnvironment(macCatalyst) || os(watchOS)
        isEqual =
          isEqual
          && lhs.activityType == rhs.activityType
          && lhs.allowsBackgroundLocationUpdates == rhs.allowsBackgroundLocationUpdates
      #endif
      isEqual =
        isEqual
        && lhs.desiredAccuracy == rhs.desiredAccuracy
        && lhs.distanceFilter == rhs.distanceFilter
      #if os(iOS) || targetEnvironment(macCatalyst) || os(watchOS)
        isEqual =
          isEqual
          && lhs.headingFilter == rhs.headingFilter
          && lhs.headingOrientation == rhs.headingOrientation
      #endif
      #if os(iOS) || targetEnvironment(macCatalyst)
        isEqual =
          isEqual
          && lhs.pausesLocationUpdatesAutomatically == rhs.pausesLocationUpdatesAutomatically
          && lhs.showsBackgroundLocationIndicator == rhs.showsBackgroundLocationIndicator
      #endif
      return isEqual
    }

    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public init(
      activityType: CLActivityType? = nil,
      allowsBackgroundLocationUpdates: Bool? = nil,
      desiredAccuracy: CLLocationAccuracy? = nil,
      distanceFilter: CLLocationDistance? = nil,
      headingFilter: CLLocationDegrees? = nil,
      headingOrientation: CLDeviceOrientation? = nil,
      pausesLocationUpdatesAutomatically: Bool? = nil,
      showsBackgroundLocationIndicator: Bool? = nil
    ) {
      self.activityType = activityType
      self.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates
      self.desiredAccuracy = desiredAccuracy
      self.distanceFilter = distanceFilter
      self.headingFilter = headingFilter
      self.headingOrientation = headingOrientation
      self.pausesLocationUpdatesAutomatically = pausesLocationUpdatesAutomatically
      self.showsBackgroundLocationIndicator = showsBackgroundLocationIndicator
    }

    @available(iOS, unavailable)
    @available(macCatalyst, unavailable)
    @available(watchOS, unavailable)
    public init(
      desiredAccuracy: CLLocationAccuracy? = nil,
      distanceFilter: CLLocationDistance? = nil
    ) {
      self.desiredAccuracy = desiredAccuracy
      self.distanceFilter = distanceFilter
    }

    @available(iOS, unavailable)
    @available(macCatalyst, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    public init(
      activityType: CLActivityType? = nil,
      allowsBackgroundLocationUpdates: Bool? = nil,
      desiredAccuracy: CLLocationAccuracy? = nil,
      distanceFilter: CLLocationDistance? = nil,
      headingFilter: CLLocationDegrees? = nil,
      headingOrientation: CLDeviceOrientation? = nil
    ) {
      self.activityType = activityType
      self.allowsBackgroundLocationUpdates = allowsBackgroundLocationUpdates
      self.desiredAccuracy = desiredAccuracy
      self.distanceFilter = distanceFilter
      self.headingFilter = headingFilter
      self.headingOrientation = headingOrientation
    }
  }
}
