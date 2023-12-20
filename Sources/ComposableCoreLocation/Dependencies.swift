import Dependencies

extension DependencyValues {
  public var locationManager: LocationManager {
    get { self[LocationManager.self] }
    set { self[LocationManager.self] = newValue }
  }
}

extension LocationManager: DependencyKey {
  public static let testValue = Self.failing
  public static var liveValue = Self.live
}
