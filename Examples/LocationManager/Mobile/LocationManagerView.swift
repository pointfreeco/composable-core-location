import Combine
import ComposableArchitecture
import ComposableCoreLocation
import MapKit
import SwiftUI

private let readMe = """
  This application demonstrates how to work with CLLocationManager for getting the user's current \
  location, and MKLocalSearch for searching points of interest on the map.

  Zoom into any part of the map and tap a category to search for points of interest nearby. The \
  markers are also updated live if you drag the map around.
  """

struct LocationManagerView: View {
  @Environment(\.colorScheme) var colorScheme
  let store: StoreOf<App>

  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      ZStack {
        MapView(
          pointsOfInterest: viewStore.pointsOfInterest,
          region: viewStore.binding(get: \.region, send: App.Action.updateRegion)
        )
        .edgesIgnoringSafeArea([.all])

        VStack(alignment: .trailing) {
          Spacer()

          Button(action: { viewStore.send(.currentLocationButtonTapped) }) {
            Image(systemName: "location")
              .foregroundColor(Color.white)
              .frame(width: 60, height: 60)
              .background(Color.secondary)
              .clipShape(Circle())
              .padding([.trailing], 16)
              .padding([.bottom], 16)
          }

          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(App.State.pointOfInterestCategories, id: \.rawValue) { category in
                Button(category.displayName) { viewStore.send(.categoryButtonTapped(category)) }
                  .padding([.all], 16)
                  .background(
                    category == viewStore.pointOfInterestCategory ? Color.blue : Color.secondary
                  )
                  .foregroundColor(.white)
                  .cornerRadius(8)
              }
            }
            .padding([.leading, .trailing])
            .padding([.bottom], 32)
          }
        }
      }
      .task { await viewStore.send(.task).finish() }
      .alert(store: self.store.scope(state: \.$alert, action: App.Action.alert))
    }
  }
}

struct ContentView: View {
  var body: some View {
    NavigationView {
      Form {
        Section(
          header: Text(readMe)
            .font(.body)
            .padding([.bottom])
        ) {
          NavigationLink(
            "Go to demo",
            destination: LocationManagerView(
              store: Store(
                initialState: App.State()
              ) {
                  App()
                      .dependency(\.localSearchClient, .liveValue)
                      .dependency(\.locationManager, .live)
              }
            )
          )
        }
      }
      .navigationBarTitle("Location Manager")
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

#if DEBUG



  struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      let appView = LocationManagerView(
        store: Store(
          initialState: App.State()
        ) {
            App()
                .dependency(\.localSearchClient, .liveValue)
                .dependency(\.locationManager, .mock())
        }
      )

      return Group {
        ContentView()
        appView
        appView
          .environment(\.colorScheme, .dark)
      }
    }
  }

extension LocationManager {
    
    static func mock() -> Self {
        actor MockStore {
            let locationManagerSubject: CurrentValueSubject<LocationManager.Action, Never>
            var currentAuthorizationStatus: CLAuthorizationStatus {
                didSet {
                    locationManagerSubject.send(.didChangeAuthorization(currentAuthorizationStatus))
                }
            }
            
            var currentLocation: ComposableCoreLocation.Location? {
                didSet {
                    locationManagerSubject.send(
                        .didUpdateLocations(currentLocation.map { [$0] } ?? [])
                    )
                }
            }
            
            init(authorization: CLAuthorizationStatus) {
                self.currentAuthorizationStatus = authorization
                self.locationManagerSubject = .init(.didChangeAuthorization(currentAuthorizationStatus))
            }
            
            func update(authorization: CLAuthorizationStatus) {
                self.currentAuthorizationStatus = authorization
            }
            
            func update(location: ComposableCoreLocation.Location) {
                self.currentLocation = location
            }
        }
        
        // NB: CLLocationManager mostly does not work in SwiftUI previews, so we provide a mock
        //     manager that has all authorization allowed and mocks the device's current location
        //     to Brooklyn, NY.
        let mockLocation = Location(
            coordinate: CLLocationCoordinate2D(latitude: 40.6501, longitude: -73.94958)
        )
        let store = MockStore(authorization: .authorizedAlways)
        var manager = LocationManager.live

        manager.delegate = {
            AsyncStream { continuation in
                let cancellable = store.locationManagerSubject.sink { action in
                    continuation.yield(action)
                }
                continuation.onTermination = { _ in
                    cancellable.cancel()
                }
            }
        }
        manager.locationServicesEnabled = { true }
        manager.requestLocation = {
            await store.update(location: mockLocation)
        }
        return manager
    }
}

#endif
