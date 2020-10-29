import ComposableArchitecture
import MapKit

extension LocalSearchClient {
  public static func unimplemented(
    search: @escaping (MKLocalSearch.Request) -> Effect<
      LocalSearchResponse, LocalSearchClient.Error
    > = { _ in fatalError() }
  ) -> Self {
    Self(search: search)
  }
}
