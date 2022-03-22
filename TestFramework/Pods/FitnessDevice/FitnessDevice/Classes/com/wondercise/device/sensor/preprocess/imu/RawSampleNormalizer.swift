import Foundation
import PhysData
import RxSwift

public class RawSampleNormalizer: AbstractHasNextPipe {
    private var mSensitivities: [Double]

    /// init()
    /// - Parameters:
    ///   - mMeasurementRangeSensitivities:

    public init(mMeasurementRangeSensitivities: [RequiredSensor.IMU.MeasurementSensitivity]) {
        mSensitivities = mMeasurementRangeSensitivities.map(\.rawValue)
    }
}

// MARK: - PipeInput

extension RawSampleNormalizer: PipeInput {
    public func processRaw(timestampMs: Int64, accelerationRawSample: [Int]) {
        mProcessPipe?.process(realtimeIMUSample: processImpl(timestampMs: timestampMs, sampleGroup: [accelerationRawSample]))
    }

    public func processRaw(timestampMs: Int64, accelerationRawSample: [Int], angularVelocityRawSample: [Int]) {
        mProcessPipe?.process(realtimeIMUSample: processImpl(timestampMs: timestampMs, sampleGroup: [accelerationRawSample, angularVelocityRawSample]))
    }

    public func processRaw(timestampMs: Int64, accelerationRawSample: [Int], angularVelocityRawSample: [Int], magneticFieldRawSample: [Int]) {
        mProcessPipe?.process(realtimeIMUSample: processImpl(timestampMs: timestampMs, sampleGroup: [accelerationRawSample, angularVelocityRawSample, magneticFieldRawSample]))
    }

    private func processImpl(timestampMs: Int64, sampleGroup: [[Int]]) -> RealtimeIMUSample {
        let data = zip(mSensitivities, sampleGroup).map { sensitivity, sample in sample.map { Double($0) / sensitivity } }
        return RealtimeIMUSample(timestampMs: timestampMs, imuSample: data)
    }
}
