import Foundation
import PhysData
import RxSwift

public protocol IMUConfiguration {
    /// enableIMUMeasures()
    /// - Parameters:
    ///   - measures:
    /// - Returns: Void
    func enableIMUMeasures(measures: Set<RequiredSensor.IMU.Measure>)

    /// setMinimumMeasurementRange()
    /// - Parameters:
    ///   - measure:
    ///   - measurementRange:
    /// - Returns: Void
    func setMinimumMeasurementRange(measure: RequiredSensor.IMU.Measure, measurementRange: RequiredSensor.IMU.MeasurementRange)

    /// setMinimumMeasurementSensitivity()
    /// - Parameters:
    ///   - measure:
    ///   - measurementSensitivity:
    /// - Returns: Void
    func setMinimumMeasurementSensitivity(measure: RequiredSensor.IMU.Measure, measurementSensitivity: RequiredSensor.IMU.MeasurementSensitivity)

    /// setMeasurementUnit()
    /// - Parameters:
    ///   - measurementUnit:
    /// - Returns: Void
    func setMeasurementUnit(measurementUnit: RequiredSensor.IMU.MeasurementUnit)

    /// setSamplingRate()
    /// - Parameters:
    ///   - samplingRate:
    /// - Returns: Void
    func setSamplingRate(samplingRate: RequiredSensor.IMU.SamplingRate)

    /// setSamplingMode()
    /// - Parameters:
    ///   - samplingMode:
    /// - Returns: Void
    func setSamplingMode(samplingMode: RequiredSensor.IMU.SamplingMode)
}

public extension IMUConfiguration {
    /// configure()
    /// - Parameters:
    ///   - imu:
    /// - Returns: Void
    func configure(imu: RequiredSensor) throws {
        if case let RequiredSensor.imu(measures, minimumMeasurementRanges, minimumMeasurementSensitivities, measurementUnit, samplingRate, realtimeLevel: RequiredSensor, samplingMode) = imu {
            if measures.isEmpty {
                throw FitnessDeviceError.illegalArgumentException("no measures specified")
            }
            self.enableIMUMeasures(measures: measures)
            for (measure, measurementRange) in minimumMeasurementRanges {
                self.setMinimumMeasurementRange(measure: measure, measurementRange: measurementRange)
            }
            for (measure, measurementSensitivity) in minimumMeasurementSensitivities {
                self.setMinimumMeasurementSensitivity(measure: measure, measurementSensitivity: measurementSensitivity)
            }
            self.setMeasurementUnit(measurementUnit: measurementUnit)
            self.setSamplingRate(samplingRate: samplingRate)
            self.setSamplingMode(samplingMode: samplingMode)
        }
    }
}
