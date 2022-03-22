import Foundation

public struct DeviceProfile {
    public var deviceType: DeviceType
    public var sensorSupport: SensorSupport

    public init(deviceType: DeviceType,
                sensorSupport: SensorSupport)
    {
        self.deviceType = deviceType
        self.sensorSupport = sensorSupport
    }

    /// isSupport()
    /// - Parameters:
    ///   - deviceRequirement:
    /// - Returns: Bool
    public func isSupport(deviceRequirement: DeviceRequirement) -> Bool {
        deviceRequirement.acceptableDeviceTypes.contains(deviceType.rawValue) && sensorSupport.isSupport(sensorRequirement: deviceRequirement.sensorRequirement)
    }
}
