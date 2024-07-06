import MapKit
import Dependencies

extension DependencyValues {
    public var localSearchClient: LocalSearchClient {
        get { self[LocalSearchClient.self] }
        set { self[LocalSearchClient.self] = newValue }
    }
}

extension LocalSearchClient: TestDependencyKey {
    public static let previewValue = Self.noop
    public static let testValue = Self.failing
}

extension LocalSearchClient {
    public static let noop = Self(
        search: { _ in try await Task.never() }
    )
}

public struct LocalSearchClient {
  public var search: @Sendable (MKLocalSearch.Request) async throws -> LocalSearchResponse

  public init(
    search: @escaping @Sendable (MKLocalSearch.Request) async throws -> LocalSearchResponse
  ) {
    self.search = search
  }
}

