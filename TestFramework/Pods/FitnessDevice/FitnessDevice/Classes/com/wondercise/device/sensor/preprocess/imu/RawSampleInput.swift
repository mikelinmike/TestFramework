import Foundation
import PhysData
import RxSwift

public class RawSampleInput: AbstractHasNextPipe {}

// MARK: - PipeInput

extension RawSampleInput: PipeInput {
    public func processRaw(timestampMs: Int64, accelerationRawSample: [Int]) {
        mProcessPipe?.process(
            realtimeIMUSample: processImpl(
                timestampMs: timestampMs,
                sampleGroup: [accelerationRawSample]
            )
        )
    }

    public func processRaw(timestampMs: Int64, accelerationRawSample: [Int], angularVelocityRawSample: [Int]) {
        mProcessPipe?.process(
            realtimeIMUSample: processImpl(
                timestampMs: timestampMs,
                sampleGroup: [accelerationRawSample, angularVelocityRawSample]
            )
        )
    }

    public func processRaw(timestampMs: Int64, accelerationRawSample: [Int], angularVelocityRawSample: [Int], magneticFieldRawSample: [Int]) {
        mProcessPipe?.process(
            realtimeIMUSample: processImpl(
                timestampMs: timestampMs,
                sampleGroup: [accelerationRawSample, angularVelocityRawSample, magneticFieldRawSample]
            )
        )
    }
}

private func processImpl(timestampMs: Int64, sampleGroup: [[Int]]) -> RealtimeIMUSample {
    let data = sampleGroup.map { $0.map { Double($0) }}
    return RealtimeIMUSample(timestampMs: timestampMs, imuSample: data)
}
