import Combine
import ComposableArchitecture
import MapKit



extension LocalSearchClient: DependencyKey {
    public static let liveValue = Self(
        search: { request in
            let response = try await MKLocalSearch(request: request).start()
            return LocalSearchResponse(response: response)
        }
    )
}
