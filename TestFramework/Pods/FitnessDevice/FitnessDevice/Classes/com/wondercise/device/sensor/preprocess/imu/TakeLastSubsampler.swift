import Foundation
import PhysData
import RxSwift

public class TakeLastSubsampler: Subsampler {
    var mLatestSample: RealtimeIMUSample?

    /// init()
    /// - Parameters:
    ///   - subSampleFactor:
    override public init(mSubsampleFactor subSampleFactor: UInt) {
        super.init(mSubsampleFactor: subSampleFactor)
    }

    override public func group(realtimeIMUSample: RealtimeIMUSample) {
        mLatestSample = realtimeIMUSample
    }

    override public func emitSubsample(groupSize: Int) {
        mProcessPipe?.process(realtimeIMUSample: mLatestSample!)
    }
}
