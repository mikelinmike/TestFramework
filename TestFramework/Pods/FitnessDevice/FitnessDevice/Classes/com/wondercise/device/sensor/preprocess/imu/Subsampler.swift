import Foundation
import PhysData
import RxSwift

open class Subsampler: AbstractHasNextPipe {
    let mSubsampleFactor: UInt
    private var mCounter = 0

    /// init()
    /// - Parameters:
    ///   - mSubsampleFactor:

    init(mSubsampleFactor: UInt) {
        self.mSubsampleFactor = mSubsampleFactor
    }

    override public func reset() {
        mCounter = 0
        super.reset()
    }

    /// group()
    /// - Parameters:
    ///   - realtimeIMUSample:
    /// - Returns: Void
    open func group(realtimeIMUSample: RealtimeIMUSample) {
        fatalError("not been impl")
    }

    /// emitSubsample()
    /// - Parameters:
    ///   - groupSize:
    /// - Returns: Void
    open func emitSubsample(groupSize: Int) {
        fatalError("not been impl")
    }
}

// MARK: - ProcessPipe

extension Subsampler: ProcessPipe {
    /// process()
    /// - Parameters:
    ///   - realtimeIMUSample:
    /// - Returns: Void
    public func process(realtimeIMUSample: RealtimeIMUSample) {
        mCounter += 1
        group(realtimeIMUSample: realtimeIMUSample)
        if mCounter == mSubsampleFactor {
            emitSubsample(groupSize: mCounter)
            mCounter = 0
        }
    }
}
