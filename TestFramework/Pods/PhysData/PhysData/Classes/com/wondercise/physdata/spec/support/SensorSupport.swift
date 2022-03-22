import Foundation

public class SensorSupport {
    public var supportedSensors: [String: SupportedSensor] = [:]

    /// init()
    /// - Parameters:
    ///   - supportedSensors:

    public init(supportedSensors: Set<SupportedSensor>) {
        for i in supportedSensors {
            self.supportedSensors[i.requiredSensorName] = i
        }
    }

    /// isSupport()
    /// - Parameters:
    ///   - sensorRequirement:
    /// - Returns: Bool
    public func isSupport(sensorRequirement: SensorRequirement) -> Bool {
        sensorRequirement.requiredSensors.map { requiredSensor in
            let name = requiredSensor.name
            if let supportedSensor = supportedSensors[name] {
                return supportedSensor.isSupport(requiredSensor: requiredSensor)
            }
            return false
        }.allSatisfy { $0 }
    }

    /// intersect()
    /// - Parameters:
    ///   - sensorSupportA:
    ///   - sensorSupportB:
    /// - Returns: SensorSupport
    public static func intersect(sensorSupportA: SensorSupport, sensorSupportB: SensorSupport) -> SensorSupport {
        let intersectedSensorName: Set<String> = Set(sensorSupportA.supportedSensors.keys).intersection(Set(sensorSupportB.supportedSensors.keys))

        var intersectedSupportedSensors: Set<SupportedSensor> = []
        for key in intersectedSensorName {
            let aSupportedSensor = sensorSupportA.supportedSensors[key]!
            let bSupportedSensor = sensorSupportB.supportedSensors[key]!

            if let supportSensor = aSupportedSensor.intersect(supportedSensor: bSupportedSensor) {
                intersectedSupportedSensors.insert(supportSensor)
            } else {
                return SensorSupport(supportedSensors: [])
            }
        }
        return SensorSupport(supportedSensors: intersectedSupportedSensors)
    }
}
