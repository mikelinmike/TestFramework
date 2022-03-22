import Foundation
import PhysData
import RxSwift

private let ALMOST_SAME_LENGTH_MARGIN_MS = 100

public class TimeSlot: AbstractHasNextPipe {
    private let mTimeoutMs: Int64
    private let mTimestampCalibrationInMilliseconds: Int
    private let mSamplingPeriodMs: Int
    private let mSubSamplingPeriodMs: Int
    private let mAlmostSameLengthMarginSampleCount: Int
    private var mLastFlushTimestamp: Int64 = -1
    private var mSampleSubject = PublishSubject<RealtimeIMUSample>.init()
    private var mIntervalObservableDisposable: Disposable?
    private var mBackupBuffer: [RealtimeIMUSample] = []

    /// init()
    /// - Parameters:
    ///   - timeoutMilliseconds:
    ///   - samplingRate:
    ///   - outputSamplingRate:

    public init(timeoutMilliseconds: Int, timestampCalibrationInMilliseconds: Int, samplingRate: RequiredSensor.IMU.SamplingRate, outputSamplingRate: RequiredSensor.IMU.SamplingRate) {
        mTimeoutMs = Int64(timeoutMilliseconds)
        mTimestampCalibrationInMilliseconds = timestampCalibrationInMilliseconds
        mSamplingPeriodMs = samplingRate.periodInMilliseconds
        mSubSamplingPeriodMs = outputSamplingRate.periodInMilliseconds
        mAlmostSameLengthMarginSampleCount = ALMOST_SAME_LENGTH_MARGIN_MS / mSamplingPeriodMs
        mBackupBuffer.reserveCapacity(Int(ceil(Float(mTimeoutMs) / 1000.0 * Float(samplingRate.rawValue))))
    }

    override public func reset() {
        mLastFlushTimestamp = -1
        mBackupBuffer.removeAll()
        stopSlotting()
        super.reset()
    }

    /// stopSlotting()
    /// - Returns: Void
    public func stopSlotting() {
        mIntervalObservableDisposable?.dispose()
    }

    private func flushBuffer(buffer: [RealtimeIMUSample]) {
        var buffer = buffer
        let duration = Int(Int64(Date().timeIntervalSince1970 * 1000) - mLastFlushTimestamp)
        print("TIME_SLOT", "flushBuffer timeout ")

        let expectedSampleCount = duration / mSamplingPeriodMs
        let expectedSubsampleCount = duration / mSubSamplingPeriodMs
        if expectedSubsampleCount == 0 { // Very unlikely to happen
            return
        }
        // align the slot boundary to subsampling timing unit
        let firstSubsampleTimestamp = mLastFlushTimestamp - Int64(mTimestampCalibrationInMilliseconds)
        mLastFlushTimestamp += Int64(expectedSubsampleCount * mSubSamplingPeriodMs)
        var bufferSize = buffer.count
        print("TIME_SLOT", "bufferSize \(bufferSize)")
        if bufferSize == 0 {
            let backupBufferSize = mBackupBuffer.count
            if backupBufferSize == 0 {
                return
            }
            buffer.append(contentsOf: mBackupBuffer)
            bufferSize = backupBufferSize
            // notify no Data
        }
        let slottedSampleCountDiff = expectedSampleCount - bufferSize
        if slottedSampleCountDiff < -mAlmostSameLengthMarginSampleCount {
            print("TIME_SLOT", "GREATER \(slottedSampleCountDiff)")
            for i in stride(from: bufferSize - 1, through: expectedSampleCount, by: -1) {
                buffer.remove(at: i)
            }
        } else if slottedSampleCountDiff > mAlmostSameLengthMarginSampleCount {
            print("TIME_SLOT", "LESSER \(slottedSampleCountDiff)")
            let lastSample = buffer[bufferSize - 1]
            for _ in 0 ..< slottedSampleCountDiff {
                buffer.append(lastSample.clone())
            }
        }
        subsampleProcess(buffer: buffer, desiredSampleNumber: expectedSubsampleCount, firstSubsampleTimestamp: firstSubsampleTimestamp)
        mBackupBuffer.removeAll()
        mBackupBuffer.append(contentsOf: buffer)
        buffer.removeAll()
    }

    private func subsampleProcess(buffer: [RealtimeIMUSample], desiredSampleNumber: Int, firstSubsampleTimestamp: Int64) {
        let bufferSize = buffer.count
        for i in 0 ..< desiredSampleNumber {
            var begin = Int((Float(i * bufferSize) / Float(desiredSampleNumber)).rounded()) // >= 0
            var end = Int((Float((i + 1) * bufferSize) / Float(desiredSampleNumber)).rounded()) // <= desiredSampleNumber

            if begin == end {
                if end == bufferSize {
                    begin = end - 1
                } else {
                    end = begin + 1
                }
            }
            let sampleTimestamp = firstSubsampleTimestamp + Int64(i * mSubSamplingPeriodMs)
            mProcessPipe?.process(realtimeIMUSample: generateSubsample(sampleTimestamp: sampleTimestamp, buffer: buffer, begin: begin, end: end))
        }
    }

    private func generateSubsample(sampleTimestamp: Int64, buffer: [RealtimeIMUSample], begin: Int, end: Int) -> RealtimeIMUSample {
        let resultSample = cloneImuSampleWithGivenTimestamp(timestamp: sampleTimestamp, realtimeIMUSample: buffer[begin])
        var tmpImuSample = resultSample.imuSample
        let count = Double(end - begin)
        // caching innerSize may cause the future dimension changes being not compatible
        for i in begin + 1 ..< end {
            let imuSample = buffer[i].imuSample
            for sensorIndex in tmpImuSample.indices {
                for xyzAxis in tmpImuSample[sensorIndex].indices {
                    tmpImuSample[sensorIndex][xyzAxis] += imuSample[sensorIndex][xyzAxis]
                }
            }
        }

        for sensorIndex in tmpImuSample.indices {
            for xyzAxis in tmpImuSample[sensorIndex].indices {
                tmpImuSample[sensorIndex][xyzAxis] /= count
            }
        }

        resultSample.imuSample = tmpImuSample
        return resultSample
    }
}

// MARK: - ProcessPipe

extension TimeSlot: ProcessPipe {
    public func process(realtimeIMUSample: RealtimeIMUSample) {
        if mLastFlushTimestamp < 0 {
            mLastFlushTimestamp = Int64(Date().timeIntervalSince1970 * 1000)
            mIntervalObservableDisposable = mSampleSubject
                .buffer(
                    timeSpan: RxTimeInterval.milliseconds(Int(mTimeoutMs)),
                    count: -1,
                    scheduler: SerialDispatchQueueScheduler(internalSerialQueueName: "TimeSlot")
                )
                .subscribe(onNext: {
                    [weak self] realtimeIMUSample in
                        guard let self = self else { return }
                        self.flushBuffer(buffer: realtimeIMUSample)
                })
        }
        mSampleSubject.onNext(realtimeIMUSample)
    }
}

private func cloneImuSampleWithGivenTimestamp(timestamp: Int64, realtimeIMUSample: RealtimeIMUSample) -> RealtimeIMUSample {
    RealtimeIMUSample(timestampMs: timestamp, imuSample: realtimeIMUSample.imuSample)
}
