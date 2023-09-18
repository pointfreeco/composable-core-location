import Combine
import XCTestDynamicOverlay

extension AnyPublisher {
  static func unimplemented(_ prefix: String, file: StaticString = #file, line: UInt = #line) -> Self {
    .fireAndForget {
      XCTFail("\(prefix.isEmpty ? "" : "\(prefix) - ")An unimplemented publisher ran.", file: file, line: line)
    }
  }
  
  static func fireAndForget(_ work: @escaping () throws -> Void) -> Self {
    Deferred {
      try? work()
      return Empty<Output, Failure>()
    }
    .eraseToAnyPublisher()
  }
}
