import Foundation
import PhysData
import RxSwift

public class SampleCountingComplementer: AbstractHasNextPipe {
    private var mComplementSampleCount: Int
    private var mSamplingPeriodImMilliseconds: Int64
    private var mInputSampleCounter: UInt64 = 0
    private var mComplementCounter: Int64 = 0
    private var mPreviousImuSample: RealtimeIMUSample?

    /// init()
    /// - Parameters:
    ///   - mComplementSampleCount:
    ///   - samplingRate:

    public init(mComplementSampleCount: Int, samplingRate: RequiredSensor.IMU.SamplingRate) {
        self.mComplementSampleCount = mComplementSampleCount
        mSamplingPeriodImMilliseconds = Int64(samplingRate.periodInMilliseconds)
    }

    override public func reset() {
        mInputSampleCounter = 0
        mComplementCounter = 0
        super.reset()
    }

    private func computeNextSampleTimestamp(realtimeIMUSample: RealtimeIMUSample) -> Int64 {
        realtimeIMUSample.timestampMilliseconds + mComplementCounter * mSamplingPeriodImMilliseconds
    }
}

// MARK: - ProcessPipe

extension SampleCountingComplementer: ProcessPipe {
    public func process(realtimeIMUSample: RealtimeIMUSample) {
        if let mProcessPipe = mProcessPipe,
           let mPreviousImuSample = mPreviousImuSample
        {
            let sampleArray = realtimeIMUSample.imuSample
            mInputSampleCounter += 1
            if mInputSampleCounter % UInt64(mComplementSampleCount) == 0 {
                mComplementCounter += 1
                let previousArray = mPreviousImuSample.imuSample
                let interpolatedArray = zip(sampleArray, previousArray).map { interpolate(currentArray: $0, previousArray: $1) }
                mProcessPipe.process(
                    realtimeIMUSample: RealtimeIMUSample(
                        timestampMs: computeNextSampleTimestamp(realtimeIMUSample: mPreviousImuSample),
                        imuSample: interpolatedArray
                    )
                )
            } else if (Int(mInputSampleCounter) + 1) % mComplementSampleCount == 0 {
                self.mPreviousImuSample = realtimeIMUSample.clone()
            }
            let timestampRevisedSample = RealtimeIMUSample(
                timestampMs: computeNextSampleTimestamp(realtimeIMUSample: realtimeIMUSample),
                imuSample: realtimeIMUSample.imuSample
            )
            mProcessPipe.process(realtimeIMUSample: timestampRevisedSample)
        }
    }
}

private func interpolate(currentArray: [Double], previousArray: [Double]) -> [Double] {
    [(currentArray[0] + previousArray[0]) / 2,
     (currentArray[1] + previousArray[1]) / 2,
     (currentArray[2] + previousArray[2]) / 2]
}
