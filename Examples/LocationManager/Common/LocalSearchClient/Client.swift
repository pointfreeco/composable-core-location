import ComposableArchitecture
import MapKit

public struct LocalSearchClient {
  public var search: (MKLocalSearch.Request) -> EffectPublisher<LocalSearchResponse, Error>

  public init(
    search: @escaping (MKLocalSearch.Request) -> EffectPublisher<LocalSearchResponse, Error>
  ) {
    self.search = search
  }

  public struct Error: Swift.Error, Equatable {
    public init() {}
  }
}
