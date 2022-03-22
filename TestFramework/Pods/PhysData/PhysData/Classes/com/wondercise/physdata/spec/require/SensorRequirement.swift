import Foundation

public struct SensorRequirement {
    public var requiredSensors: Set<RequiredSensor>

    public init(requiredSensors: Set<RequiredSensor>) {
        self.requiredSensors = requiredSensors
    }
}
