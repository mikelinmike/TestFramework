import Foundation

public enum RequiredSensor: Hashable {
    case imu(measures: Set<RequiredSensor.IMU.Measure>, minimumMeasurementRanges: [RequiredSensor.IMU.Measure: RequiredSensor.IMU.MeasurementRange], minimumMeasurementSensitivities: [RequiredSensor.IMU.Measure: RequiredSensor.IMU.MeasurementSensitivity], measurementUnit: RequiredSensor.IMU.MeasurementUnit, samplingRate: RequiredSensor.IMU.SamplingRate, realtimeLevel: RequiredSensor.IMU.RealtimeLevel, samplingMode: RequiredSensor.IMU.SamplingMode)
    case heartMonitorSensor(measures: Set<RequiredSensor.HeartMonitorSensor.Measure>)
    public var name: String {
        switch self {
        case let .imu(measures, minimumMeasurementRanges, minimumMeasurementSensitivities, measurementUnit, samplingRate, realtimeLevel, samplingMode):
            return "IMU"
        case let .heartMonitorSensor(measures):
            return "HeartMonitorSensor"
        }
    }
}

// MARK: - Inner Class of RequiredSensor

public extension RequiredSensor {
    // MARK: - HeartMonitorSensor

    enum HeartMonitorSensor {}

    // MARK: - IMU

    enum IMU {}
}

// MARK: - Inner Class of RequiredSensor.HeartMonitorSensor

public extension RequiredSensor.HeartMonitorSensor {
    // MARK: - Measure

    enum Measure {
        case heartRate
        case heartRateVariability
    }
}

// MARK: - Inner Class of RequiredSensor.IMU

public extension RequiredSensor.IMU {
    // MARK: - Measure

    enum Measure {
        case acceleration
        case angularVelocity
        case magneticField
    }

    // MARK: - MeasurementRange

    enum MeasurementRange: Double {
        case acceleration4g = 4.0
        case acceleration8g = 8.0
        case acceleration16g = 16.0
        case angularVelocity500dps = 500.0
        case angularVelocity1000dps = 1000.0
        case angularVelocity2000dps = 2000.0
    }

    // MARK: - MeasurementSensitivity

    enum MeasurementSensitivity: Double {
        case acceleration8192 = 8192.0
        case acceleration4096 = 4096.0
        case acceleration2048 = 2048.0
        case acceleration1024 = 1024.0
        case angularVelocity65536 = 65.536
        case angularVelocity32768 = 32.768
        case angularVelocity16384 = 16.384
        case unknownBelieveHigh = 9_223_372_036_854_775_807 // long max
        case unknownBelieveLow = 0.0
    }

    // MARK: - MeasurementUnit

    enum MeasurementUnit {
        case raw
        case standard
    }

    // MARK: - SamplingRate

    enum SamplingRate: Int {
        case rate25 = 25
        case rate50 = 50
        case rate100 = 100
        case rate200 = 200
        public var periodInMilliseconds: Int {
            1000 / rawValue
        }

        public var signedFrequency: Int {
            rawValue
        }

        /// fromFrequency()
        /// - Parameters:
        ///   - frequency:
        /// - Returns: SamplingRate
        public static func fromFrequency(frequency: Int) throws -> SamplingRate {
            if let samplingRate = SamplingRate(rawValue: frequency) {
                return samplingRate
            } else {
                throw PhysDataError.illegalArgumentException("The frequency is invalid")
            }
        }
    }

    // MARK: - RealtimeLevel

    enum RealtimeLevel: Int {
        case high = 0
        case medium = 1
        case low = 2
    }

    // MARK: - SamplingMode

    enum SamplingMode {
        case freeRun
        case steadyAlign
    }
}
