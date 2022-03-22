import Foundation
import PhysData
import RxSwift

public class RequirementCompatibleRangeSensitivities {
    private let mRangeSensitivitiesAscendedByRange: [SupportedSensor.IMU.MeasurementRangeSensitivity]
    private var mCompatibleRangeSensitivities: [SupportedSensor.IMU.MeasurementRangeSensitivity] = []
    private var mMinimumRangeRequired = false
    private var mMinimumSensitivityRequired = false

    /// init()
    /// - Parameters:
    ///   - supportedMeasurementRangeSensitivities:

    public init(supportedMeasurementRangeSensitivities: [SupportedSensor.IMU.MeasurementRangeSensitivity]) {
        mRangeSensitivitiesAscendedByRange =
            supportedMeasurementRangeSensitivities.sorted(by: { $0.measurementRange.rawValue < $1.measurementRange.rawValue })
    }

    /// filterByRange()
    /// - Parameters:
    ///   - measurementRange:
    /// - Returns: Void
    public func filterByRange(measurementRange: RequiredSensor.IMU.MeasurementRange) {
        if let compatibleIndex = mCompatibleRangeSensitivities.index(where: { $0.measurementRange.rawValue >= measurementRange.rawValue }) {
            mCompatibleRangeSensitivities.removeSubrange(0 ..< compatibleIndex)
        }
    }

    /// filterBySensitivity()
    /// - Parameters:
    ///   - measurementSensitivity:
    /// - Returns: Void
    public func filterBySensitivity(measurementSensitivity: RequiredSensor.IMU.MeasurementSensitivity) {
        var reversedView = Array(mCompatibleRangeSensitivities.reversed())
        if let compatibleIndex = reversedView.index(where: { $0.measurementSensitivity.rawValue >= measurementSensitivity.rawValue }) {
            reversedView.removeSubrange(0 ..< compatibleIndex)
        }
        mCompatibleRangeSensitivities = reversedView.reversed()
    }

    /// pick()
    /// - Returns: SupportedSensor.IMU.MeasurementRangeSensitivity
    public func pick() -> SupportedSensor.IMU.MeasurementRangeSensitivity {
        if !mMinimumRangeRequired, mMinimumSensitivityRequired {
            return mCompatibleRangeSensitivities.first!
        } else {
            return mCompatibleRangeSensitivities.last!
        }
    }

    /// reset()
    /// - Returns: Void
    public func reset() {
        mCompatibleRangeSensitivities.removeAll()
        mCompatibleRangeSensitivities.append(contentsOf: mRangeSensitivitiesAscendedByRange)
        mMinimumRangeRequired = false
        mMinimumSensitivityRequired = false
    }
}
