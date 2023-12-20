import ComposableArchitecture
import ComposableCoreLocation
import MapKit

public struct PointOfInterest: Equatable, Hashable {
  public let coordinate: CLLocationCoordinate2D
  public let subtitle: String?
  public let title: String?

  public init(
    coordinate: CLLocationCoordinate2D,
    subtitle: String?,
    title: String?
  ) {
    self.coordinate = coordinate
    self.subtitle = subtitle
    self.title = title
  }
}

enum CancelID: Int {
  case locationManager
  case search
}

public struct App: Reducer {
  
  public struct State: Equatable {
    @PresentationState public var alert: AlertState<Action.Alert>?
    public var isRequestingCurrentLocation = false
    public var pointOfInterestCategory: MKPointOfInterestCategory?
    public var pointsOfInterest: [PointOfInterest] = []
    public var region: CoordinateRegion?

    public init(
      alert: AlertState<Action.Alert>? = nil,
      isRequestingCurrentLocation: Bool = false,
      pointOfInterestCategory: MKPointOfInterestCategory? = nil,
      pointsOfInterest: [PointOfInterest] = [],
      region: CoordinateRegion? = nil
    ) {
      self.alert = alert
      self.isRequestingCurrentLocation = isRequestingCurrentLocation
      self.pointOfInterestCategory = pointOfInterestCategory
      self.pointsOfInterest = pointsOfInterest
      self.region = region
    }

    public static let pointOfInterestCategories: [MKPointOfInterestCategory] = [
      .cafe,
      .museum,
      .nightlife,
      .park,
      .restaurant,
    ]
  }
  
  public enum Action: Equatable {
    case task
    case categoryButtonTapped(MKPointOfInterestCategory)
    case currentLocationButtonTapped
    case localSearchResponse(TaskResult<LocalSearchResponse>)
    case locationManager(LocationManager.Action)
    case updateRegion(CoordinateRegion?)
    case startRequestingCurrentLocation
    case setAlert(AlertState<Action.Alert>?)
    case alert(PresentationAction<Alert>)
    
    public enum Alert: Equatable {
      case dismissButtonTapped
    }
  }
  
  @Dependency(\.localSearchClient) var localSearch
  @Dependency(\.locationManager) var locationManager
  
  public var body: some ReducerOf<Self> {
    CombineReducers {
      location
      
      Reduce { state, action in
        switch action {
        case .task:
          return .run { send in
            await withTaskGroup(of: Void.self) { group in
              group.addTask {
                await withTaskCancellation(id: CancelID.locationManager, cancelInFlight: true) {
                  for await action in await locationManager.delegate() {
                    await send(.locationManager(action), animation: .default)
                  }
                }
              }
            }
          }
          
        case let .categoryButtonTapped(category):
          guard category != state.pointOfInterestCategory else {
            state.pointOfInterestCategory = nil
            state.pointsOfInterest = []
            return .cancel(id: CancelID.search)
          }
          
          state.pointOfInterestCategory = category
          
          let request = MKLocalSearch.Request()
          request.pointOfInterestFilter = MKPointOfInterestFilter(including: [category])
          if let region = state.region?.asMKCoordinateRegion {
            request.region = region
          }
          
          return .run { send in
            await send(
              .localSearchResponse(
                TaskResult {
                  try await localSearch.search(request)
                }
              )
            )
          }
          .cancellable(id: CancelID.search, cancelInFlight: true)
          
        case .currentLocationButtonTapped:
          return .run { send in
            guard await locationManager.locationServicesEnabled() else {
              await send(.setAlert(.init(title: TextState("Location services are turned off."))))
              return
            }
              
            switch await locationManager.authorizationStatus() {
            case .notDetermined:
              await send(.startRequestingCurrentLocation)
              
            case .restricted:
              await send(.setAlert(.init(title: TextState("Please give us access to your location in settings."))))
              
            case .denied:
              await send(.setAlert(.init(title: TextState("Please give us access to your location in settings."))))
              
            case .authorizedAlways, .authorizedWhenInUse:
              await locationManager.requestLocation()
              
            @unknown default:
              break
            }
          }
          
        case .startRequestingCurrentLocation:
          state.isRequestingCurrentLocation = true
          return .run { send in
            #if os(macOS)
            await locationManager.requestAlwaysAuthorization()
            #else
            await locationManager.requestWhenInUseAuthorization()
            #endif
          }
            
        case let .localSearchResponse(.success(response)):
          state.pointsOfInterest = response.mapItems.map { item in
            PointOfInterest(
              coordinate: item.placemark.coordinate,
              subtitle: item.placemark.subtitle,
              title: item.name
            )
          }
          return .none
          
        case .localSearchResponse(.failure(let error)):
          #if DEBUG
          state.alert = .init(title: TextState(error.localizedDescription))
          #else
          state.alert = .init(title: TextState("Could not perform search. Please try again."))
          #endif
          return .none
          
        case .locationManager:
          return .none
          
        case let .updateRegion(region):
          state.region = region
          
          guard
            let category = state.pointOfInterestCategory,
            let region = state.region?.asMKCoordinateRegion
          else { return .none }
          
          let request = MKLocalSearch.Request()
          request.pointOfInterestFilter = MKPointOfInterestFilter(including: [category])
          request.region = region
          return .run { send in
            await send(
              .localSearchResponse(
                TaskResult {
                  try await localSearch.search(request)
                }
              )
            )
          }
          .cancellable(id: CancelID.search, cancelInFlight: true)
          
        case .setAlert(let alert):
          state.alert = alert
          return .none
        case .alert:
          return .none
        }
      }
    }
    .ifLet(\.$alert, action: /Action.alert)
    .signpost()
    ._printChanges()
  }
  
  @ReducerBuilder<State, Action>
  var location: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .locationManager(.didChangeAuthorization(.authorizedAlways)),
              .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):
        return state.isRequestingCurrentLocation ? .run { _ in await locationManager.requestLocation() } : .none
        
      case .locationManager(.didChangeAuthorization(.denied)):
        if state.isRequestingCurrentLocation {
          state.alert = .init(
            title: TextState("Location makes this app better. Please consider giving us access.")
          )
          state.isRequestingCurrentLocation = false
        }
        return .none
        
      case .locationManager(.didUpdateLocations(let locations)):
        state.isRequestingCurrentLocation = false
        guard let location = locations.first else { return .none }
        state.region = CoordinateRegion(
          center: location.coordinate,
          span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        return .none
        
      default:
        return .none
      }
    }
  }
}

extension PointOfInterest {
  // NB: CLLocationCoordinate2D doesn't conform to Equatable
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.coordinate.latitude == rhs.coordinate.latitude
      && lhs.coordinate.longitude == rhs.coordinate.longitude
      && lhs.subtitle == rhs.subtitle
      && lhs.title == rhs.title
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(coordinate.latitude)
    hasher.combine(coordinate.longitude)
    hasher.combine(title)
    hasher.combine(subtitle)
  }
}
