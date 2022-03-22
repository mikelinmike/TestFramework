import Foundation
import RxSwift

public protocol HasNextPipe: Pipe {
    /// next()
    /// - Parameters:
    ///   - nextPipe:
    /// - Returns: I
    func next<I: ProcessPipe>(nextPipe: I) -> I
}
