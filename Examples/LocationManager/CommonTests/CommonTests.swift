import Combine
import ComposableArchitecture
import ComposableCoreLocation
import CoreLocation
import MapKit
import XCTest

#if os(iOS)
  import LocationManagerMobile
#elseif os(macOS)
  import LocationManagerDesktop
#endif

class LocationManagerTests: XCTestCase {
  func testRequestLocation_Allow() {
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment(
        localSearch: .failing,
        locationManager: .failing
      )
    )

    var didRequestInUseAuthorization = false
    var didRequestLocation = false
    let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()

    store.environment.locationManager.authorizationStatus = { .notDetermined }
    store.environment.locationManager.delegate = { locationManagerSubject.eraseToEffect() }
    store.environment.locationManager.locationServicesEnabled = { true }
    store.environment.locationManager.requestLocation = {
      .fireAndForget { didRequestLocation = true }
    }

    #if os(iOS)
      store.environment.locationManager.requestWhenInUseAuthorization = {
        .fireAndForget { didRequestInUseAuthorization = true }
      }
    #elseif os(macOS)
      store.environment.locationManager.requestAlwaysAuthorization = {
        .fireAndForget { didRequestInUseAuthorization = true }
      }
    #endif

    let currentLocation = Location(
      altitude: 0,
      coordinate: CLLocationCoordinate2D(latitude: 10, longitude: 20),
      course: 0,
      horizontalAccuracy: 0,
      speed: 0,
      timestamp: Date(timeIntervalSince1970: 1_234_567_890),
      verticalAccuracy: 0
    )

    store.send(.onAppear)

    // Tap on the button to request current location
    store.send(.currentLocationButtonTapped) {
      $0.isRequestingCurrentLocation = true
    }
    XCTAssertTrue(didRequestInUseAuthorization)

    // Simulate being given authorized to access location
    locationManagerSubject.send(.didChangeAuthorization(.authorizedAlways))
    store.receive(.locationManager(.didChangeAuthorization(.authorizedAlways)))
    XCTAssertTrue(didRequestLocation)

    // Simulate finding the user's current location
    locationManagerSubject.send(.didUpdateLocations([currentLocation]))
    store.receive(.locationManager(.didUpdateLocations([currentLocation]))) {
      $0.isRequestingCurrentLocation = false
      $0.region = CoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 10, longitude: 20),
        span: MKCoordinateSpan.init(latitudeDelta: 0.05, longitudeDelta: 0.05)
      )
    }

    locationManagerSubject.send(completion: .finished)
  }

  func testRequestLocation_Deny() {
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment(
        localSearch: .failing,
        locationManager: .failing
      )
    )

    var didRequestInUseAuthorization = false
    let locationManagerSubject = PassthroughSubject<LocationManager.Action, Never>()

    store.environment.locationManager.authorizationStatus = { .notDetermined }
    store.environment.locationManager.delegate = { locationManagerSubject.eraseToEffect() }
    store.environment.locationManager.locationServicesEnabled = { true }

    #if os(iOS)
      store.environment.locationManager.requestWhenInUseAuthorization = {
        .fireAndForget { didRequestInUseAuthorization = true }
      }
    #elseif os(macOS)
      store.environment.locationManager.requestAlwaysAuthorization = {
        .fireAndForget { didRequestInUseAuthorization = true }
      }
    #endif

    store.send(.onAppear)

    store.send(.currentLocationButtonTapped) {
      $0.isRequestingCurrentLocation = true
    }
    XCTAssertTrue(didRequestInUseAuthorization)

    // Simulate the user denying location access
    locationManagerSubject.send(.didChangeAuthorization(.denied))
    store.receive(.locationManager(.didChangeAuthorization(.denied))) {
      $0.alert = .init(
        title: TextState("Location makes this app better. Please consider giving us access.")
      )
      $0.isRequestingCurrentLocation = false
    }

    locationManagerSubject.send(completion: .finished)
  }

  func testSearchPointsOfInterest_TapCategory() {
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment(
        localSearch: .failing,
        locationManager: .failing
      )
    )

    let mapItem = MapItem(
      isCurrentLocation: false,
      name: "Blob's Cafe",
      phoneNumber: nil,
      placemark: Placemark(),
      pointOfInterestCategory: .cafe,
      timeZone: nil,
      url: nil
    )
    let localSearchResponse = LocalSearchResponse(
      boundingRegion: MKCoordinateRegion(),
      mapItems: [mapItem]
    )

    store.environment.localSearch.search = { _ in EffectPublisher(value: localSearchResponse) }

    store.send(.categoryButtonTapped(.cafe)) {
      $0.pointOfInterestCategory = .cafe
    }
    store.receive(.localSearchResponse(.success(localSearchResponse))) {
      $0.pointsOfInterest = [
        PointOfInterest(
          coordinate: CLLocationCoordinate2D(),
          subtitle: nil,
          title: "Blob's Cafe"
        )
      ]
    }
  }

  func testSearchPointsOfInterest_PanMap() {
    let store = TestStore(
      initialState: AppState(
        pointOfInterestCategory: .cafe
      ),
      reducer: appReducer,
      environment: AppEnvironment(
        localSearch: .failing,
        locationManager: .failing
      )
    )

    let mapItem = MapItem(
      isCurrentLocation: false,
      name: "Blob's Cafe",
      phoneNumber: nil,
      placemark: Placemark(),
      pointOfInterestCategory: .cafe,
      timeZone: nil,
      url: nil
    )
    let localSearchResponse = LocalSearchResponse(
      boundingRegion: MKCoordinateRegion(),
      mapItems: [mapItem]
    )

    store.environment.localSearch.search = { _ in EffectPublisher(value: localSearchResponse) }

    let coordinateRegion = CoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 10, longitude: 20),
      span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 2)
    )

    store.send(.updateRegion(coordinateRegion)) {
      $0.region = coordinateRegion
    }
    store.receive(.localSearchResponse(.success(localSearchResponse))) {
      $0.pointsOfInterest = [
        PointOfInterest(
          coordinate: CLLocationCoordinate2D(),
          subtitle: nil,
          title: "Blob's Cafe"
        )
      ]
    }
  }
}
