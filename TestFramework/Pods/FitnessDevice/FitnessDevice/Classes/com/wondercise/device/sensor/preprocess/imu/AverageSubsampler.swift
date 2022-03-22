import Foundation
import PhysData
import RxSwift

public class AverageSubsampler: Subsampler {
    var mAccumulatedProcessedSample: RealtimeIMUSample?
    /// init()
    /// - Parameters:
    ///   - subSampleFactor:
    override public init(mSubsampleFactor subSampleFactor: UInt) {
        super.init(mSubsampleFactor: subSampleFactor)
    }

    override public func group(realtimeIMUSample: RealtimeIMUSample) {
        if let accumulatedSample = mAccumulatedProcessedSample {
            let accumulatedArray = accumulatedSample.imuSample
            let realtimeArray = realtimeIMUSample.imuSample
            for (var accumulatedmeasurement, inputmeasurement) in zip(accumulatedArray, realtimeArray) {
                for axis in accumulatedArray.indices {
                    accumulatedmeasurement[axis] += inputmeasurement[axis]
                }
            }
            accumulatedSample.imuSample = accumulatedArray
        } else {
            mAccumulatedProcessedSample = realtimeIMUSample
        }
    }

    override public func emitSubsample(groupSize: Int) {
        if let mProcessPipe = mProcessPipe {
            averageAccumulatedSample(groupSize: groupSize)
            mProcessPipe.process(realtimeIMUSample: mAccumulatedProcessedSample!)
            mAccumulatedProcessedSample = nil
        }
    }

    private func averageAccumulatedSample(groupSize: Int) {
        let accumulatedArray = mAccumulatedProcessedSample!.imuSample
        for var measurement in accumulatedArray {
            for axis in measurement.indices {
                measurement[axis] /= Double(groupSize)
            }
        }
    }

    override public func reset() {
        mAccumulatedProcessedSample = nil
        super.reset()
    }
}
