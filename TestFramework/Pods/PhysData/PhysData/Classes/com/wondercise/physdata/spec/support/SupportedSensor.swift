import Foundation

public enum SupportedSensor: Hashable {
    case imu(measures: Set<RequiredSensor.IMU.Measure>, measurementRangeSensitivities: [RequiredSensor.IMU.Measure: Set<SupportedSensor.IMU.MeasurementRangeSensitivity>], measurementUnits: Set<RequiredSensor.IMU.MeasurementUnit>, samplingRates: Set<RequiredSensor.IMU.SamplingRate>, realtimeLevelCondition: SupportedSensor.IMU.RealtimeLevelCondition)
    case heartMonitorSensor(measures: Set<RequiredSensor.HeartMonitorSensor.Measure>)
    public var requiredSensorName: String {
        if case SupportedSensor.imu = self {
            return "IMU"
        }
        if case SupportedSensor.heartMonitorSensor = self {
            return "HeartMonitorSensor"
        }
        return ""
    }

    /// isSupport()
    /// - Parameters:
    ///   - requiredSensor:
    /// - Returns: Bool
    public func isSupport(requiredSensor: RequiredSensor) -> Bool {
        // imu
        if case let RequiredSensor.imu(requiredSensorMeasures, requiredSensorMinimumMeasurementRanges, requiredSensorMinimumMeasurementSensitivities, requiredSensorMeasurementUnit, requiredSensorSamplingRate, requiredSensorRealtimeLevel, requiredSensorSamplingMode) = requiredSensor {
            if case let SupportedSensor.imu(selfMeasures, selfMeasurementRangeSensitivities, selfMeasurementUnits, selfSamplingRates, selfRealtimeLevelCondition) = self {
                return selfMeasures.isSuperset(of: requiredSensorMeasures) &&
                    selfMeasurementUnits.contains(requiredSensorMeasurementUnit) &&
                    IMU.isSupportMinimumRangeAndSensitivity(self, requiredImu: requiredSensor) &&
                    selfSamplingRates.contains(requiredSensorSamplingRate) &&
                    requiredSensorRealtimeLevel.rawValue >= IMU.realtimeLevel(self, samplingMode: requiredSensorSamplingMode).rawValue
            }
        }

        // heartMonitorSensor
        if case let RequiredSensor.heartMonitorSensor(requiredSensorMeasures) = requiredSensor {
            if case let SupportedSensor.heartMonitorSensor(selfMeasures) = self {
                return selfMeasures.isSuperset(of: requiredSensorMeasures)
            }
        }

        return false
    }

    /// intersect()
    /// - Parameters:
    ///   - supportedSensor:
    /// - Returns: SupportedSensor?
    public func intersect(supportedSensor: SupportedSensor) -> SupportedSensor? {
        // heartMonitorSensor
        if case let SupportedSensor.heartMonitorSensor(supportedSensorMeasures) = supportedSensor {
            if case let SupportedSensor.heartMonitorSensor(selfMeasures) = self {
                let measures = supportedSensorMeasures.intersection(selfMeasures)
                if !(measures.isEmpty) {
                    return SupportedSensor.heartMonitorSensor(measures: measures)
                }
            }
        }
        return nil
    }
}

// MARK: - Inner Class of SupportedSensor

public extension SupportedSensor {
    // MARK: - IMU

    enum IMU {
        /// isSupportMinimumRangeAndSensitivity()
        /// - Parameters:
        ///   - requiredImu:
        /// - Returns: Bool
        public static func isSupportMinimumRangeAndSensitivity(_ supportedSensor: SupportedSensor, requiredImu: RequiredSensor) -> Bool {
            if case let RequiredSensor.imu(requiredSensorMeasures, requiredSensorMinimumMeasurementRanges, requiredSensorMinimumMeasurementSensitivities, requiredSensorMeasurementUnit, requiredSensorSamplingRate, requiredSensorRealtimeLevel, requiredSensorSamplingMode) = requiredImu {
                if case let SupportedSensor.imu(selfMeasures, selfMeasurementRangeSensitivities, selfMeasurementUnits, selfSamplingRates, selfRealtimeLevelCondition) = supportedSensor {
                    var compatibleRangeSensitivitiesForRange = selfMeasurementRangeSensitivities.filter { measure, _ in
                        !requiredSensorMinimumMeasurementRanges.keys.contains(measure)
                    }
                    for (measure, range) in requiredSensorMinimumMeasurementRanges {
                        if let rangeSensitivities = selfMeasurementRangeSensitivities[measure] {
                            let rangeCompatibleRangeSensitivities = rangeSensitivities.filter { $0.measurementRange.rawValue >= range.rawValue
                            }
                            if !(rangeCompatibleRangeSensitivities.isEmpty) {
                                compatibleRangeSensitivitiesForRange[measure] = rangeCompatibleRangeSensitivities
                            } else { // compatible range is not found
                                return false
                            }
                        } else {
                            return false
                        }
                    }

                    for (measure, sensitivity) in requiredSensorMinimumMeasurementSensitivities {
                        if let rangeSensitivities = compatibleRangeSensitivitiesForRange[measure] {
                            let isSensitivityNotCompatible = rangeSensitivities.filter { $0.measurementSensitivity.rawValue >= sensitivity.rawValue
                            }.isEmpty
                            if isSensitivityNotCompatible {
                                return true
                            }
                        } else {
                            return false
                        }
                    }
                    return true
                }
            }
            return false
        }

        /// realtimeLevel()
        /// - Parameters:
        ///   - samplingMode:
        /// - Returns: RequiredSensor.IMU.RealtimeLevel
        public static func realtimeLevel(_ supportedSensor: SupportedSensor, samplingMode: RequiredSensor.IMU.SamplingMode) -> RequiredSensor.IMU.RealtimeLevel {
            if case let SupportedSensor.imu(selfMeasures, selfMeasurementRangeSensitivities, selfMeasurementUnits, selfSamplingRates, selfRealtimeLevelCondition) = supportedSensor {
                switch selfRealtimeLevelCondition {
                case .alwaysHigh:
                    return RequiredSensor.IMU.RealtimeLevel.high
                case .freeRunHighSteadyAlignMedium:
                    if samplingMode == RequiredSensor.IMU.SamplingMode.steadyAlign {
                        return RequiredSensor.IMU.RealtimeLevel.medium
                    } else {
                        return RequiredSensor.IMU.RealtimeLevel.high
                    }
                case .alwaysMedium:
                    return RequiredSensor.IMU.RealtimeLevel.medium
                case .alwaySlow:
                    return RequiredSensor.IMU.RealtimeLevel.low
                }
            }
            // default
            return RequiredSensor.IMU.RealtimeLevel.medium
        }
    }
}

// MARK: - Inner Class of SupportedSensor.IMU

public extension SupportedSensor.IMU {
    // MARK: - RealtimeLevelCondition

    enum RealtimeLevelCondition {
        case alwaysHigh
        case freeRunHighSteadyAlignMedium
        case alwaysMedium
        case alwaySlow
    }

    // MARK: - MeasurementRangeSensitivity

    struct MeasurementRangeSensitivity: Hashable {
        public var measurementRange: RequiredSensor.IMU.MeasurementRange
        public var measurementSensitivity: RequiredSensor.IMU.MeasurementSensitivity

        public init(measurementRange: RequiredSensor.IMU.MeasurementRange, measurementSensitivity: RequiredSensor.IMU.MeasurementSensitivity) {
            self.measurementRange = measurementRange
            self.measurementSensitivity = measurementSensitivity
        }
    }
}
