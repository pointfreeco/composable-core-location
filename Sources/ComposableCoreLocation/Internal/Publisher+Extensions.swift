import Combine
import IssueReporting

extension AnyPublisher {
  static func unimplemented(_ prefix: String, fileID: StaticString = #fileID, filePath: StaticString = #filePath, line: UInt = #line) -> Self {
    .fireAndForget {
      reportIssue("\(prefix.isEmpty ? "" : "\(prefix) - ")An unimplemented publisher ran.", fileID: fileID, filePath: filePath, line: line)
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
