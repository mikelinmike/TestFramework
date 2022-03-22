import Foundation
import PhysData
import RxSwift

public protocol ProcessPipe: Pipe {
    /// process()
    /// - Parameters:
    ///   - realtimeIMUSample:
    /// - Returns: Void
    func process(realtimeIMUSample: RealtimeIMUSample)
}

public class ProcessPipeDelegate: ProcessPipe {
    public typealias Process = (_ realtimeIMUSample: RealtimeIMUSample) -> Void
    public typealias Reset = () -> Void

    private var mProcess: Process?
    private var mReset: Reset?

    public init(process: Process? = nil, reset: Reset? = nil) {
        mProcess = process
        mReset = reset
    }

    public func process(realtimeIMUSample: RealtimeIMUSample) {
        mProcess?(realtimeIMUSample)
    }

    public func reset() {
        mReset?()
    }
}
