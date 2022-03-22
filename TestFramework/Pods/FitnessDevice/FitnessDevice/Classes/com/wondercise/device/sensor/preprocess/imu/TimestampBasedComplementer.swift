import Foundation
import PhysData
import RxSwift

private let TIMESTAMP_INIT: Int64 = 0

public class TimestampBasedComplementer: AbstractHasNextPipe {
    private let mSamplingPeriodMs: Int
    private var mExpectedNextTimestamp: Int64 = TIMESTAMP_INIT
    private var mPreviousSample: RealtimeIMUSample!
    /// init()
    /// - Parameters:
    ///   - realtimeIMUSample:

    public init(samplingRate: RequiredSensor.IMU.SamplingRate) {
        mSamplingPeriodMs = 1000 / samplingRate.rawValue
    }

    override public func reset() {
        mExpectedNextTimestamp = TIMESTAMP_INIT
        super.reset()
    }
}

// MARK: - ProcessPipe

extension TimestampBasedComplementer: ProcessPipe {
    public func process(realtimeIMUSample: RealtimeIMUSample) {
        if let mProcessPipe = mProcessPipe {
            let userProcessedSampleCopy = realtimeIMUSample.clone()
            let timestamp = realtimeIMUSample.timestampMilliseconds
            if mExpectedNextTimestamp == TIMESTAMP_INIT || mExpectedNextTimestamp == timestamp {
                mPreviousSample = userProcessedSampleCopy
                mExpectedNextTimestamp = timestamp + Int64(mSamplingPeriodMs)
                mProcessPipe.process(realtimeIMUSample: realtimeIMUSample)
                return
            }
            if mExpectedNextTimestamp < timestamp {
                let lastTimestamp = mPreviousSample.timestampMilliseconds
                let imuArray = realtimeIMUSample.imuSample
                let previousImuArray = mPreviousSample.imuSample
                let inputInterval = Double(timestamp - lastTimestamp)
                while mExpectedNextTimestamp <= timestamp {
                    let ratio = Double(mExpectedNextTimestamp - lastTimestamp) / inputInterval
                    let interpolatedArray = zip(imuArray, previousImuArray).map { cs, ps in zip(cs, ps).map { c, p in ratio * (c - p) + p } }
                    let interpolatedTimestamp = mExpectedNextTimestamp

                    mExpectedNextTimestamp += Int64(mSamplingPeriodMs)
                    mProcessPipe.process(
                        realtimeIMUSample: RealtimeIMUSample(
                            timestampMs: Int64(interpolatedTimestamp),
                            imuSample: interpolatedArray
                        )
                    )
                }
            }
            mPreviousSample = userProcessedSampleCopy
        }
    }
}
