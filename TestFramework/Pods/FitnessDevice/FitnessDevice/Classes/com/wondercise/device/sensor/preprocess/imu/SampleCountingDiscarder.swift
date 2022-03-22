import Foundation
import PhysData
import RxSwift

public class SampleCountingDiscarder: AbstractHasNextPipe {
    private var mComplementSampleCount: UInt64 = 0
    private var mDiscardCounter: UInt64 = 0

    /// init()
    /// - Parameters:
    ///   - mComplementSampleCount:

    public init(mComplementSampleCount: UInt64) {
        self.mComplementSampleCount = mComplementSampleCount
        super.init()
    }

    override public func reset() {
        mDiscardCounter = 0
        super.reset()
    }
}

// MARK: - ProcessPipe

extension SampleCountingDiscarder: ProcessPipe {
    public func process(realtimeIMUSample: RealtimeIMUSample) {
        if let mProcessPipe = mProcessPipe {
            mDiscardCounter += 1
            if mDiscardCounter % mComplementSampleCount != 0 {
                mProcessPipe.process(realtimeIMUSample: realtimeIMUSample)
            }
        }
    }
}
