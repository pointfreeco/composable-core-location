import XCTestDynamicOverlay
import MapKit

extension LocalSearchClient {
  public static let failing = Self(
    search: { _ in unimplemented("LocalSearchClient.search") }
  )
}
