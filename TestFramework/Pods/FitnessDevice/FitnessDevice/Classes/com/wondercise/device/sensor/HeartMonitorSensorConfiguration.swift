import Foundation
import PhysData
import RxSwift

public protocol HeartMonitorSensorConfiguration {
    /// enableHeartMeasures()
    /// - Parameters:
    ///   - measures:
    /// - Returns: Void
    func enableHeartMeasures(measures: Set<RequiredSensor.HeartMonitorSensor.Measure>)
}

public extension HeartMonitorSensorConfiguration {
    /// configure()
    /// - Parameters:
    ///   - heartMonitorSensor:
    /// - Returns: Void
    func configure(heartMonitorSensor: RequiredSensor) throws {
        if case let RequiredSensor.heartMonitorSensor(heartMonitorSensorMeasures) = heartMonitorSensor {
            if heartMonitorSensorMeasures.isEmpty {
                throw FitnessDeviceError.illegalArgumentException("no measures specified")
            }
            enableHeartMeasures(measures: heartMonitorSensorMeasures)
        }
    }
}
