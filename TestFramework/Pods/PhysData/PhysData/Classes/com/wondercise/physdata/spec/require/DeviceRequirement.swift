import Foundation

public struct DeviceRequirement {
    public var acceptableDeviceTypes: Set<String> // Set<DeviceType> YJ
    public var sensorRequirement: SensorRequirement

    public init(acceptableDeviceTypes: Set<String>,
                sensorRequirement: SensorRequirement)
    {
        self.acceptableDeviceTypes = acceptableDeviceTypes
        self.sensorRequirement = sensorRequirement
    }

    /// pairDeviceRequirements()
    /// - Parameters:
    ///   - deviceRequirements:
    ///   - deviceProfiles:
    /// - Returns: [DeviceType: DeviceRequirement]?
    public static func measurementSensitivity(deviceRequirements: [DeviceRequirement], deviceProfiles: [DeviceProfile]) throws -> [String: DeviceRequirement]? { // YJ
        // Check the device requirements have overlapped device types
        let requirementList = deviceRequirements
        var profiles = deviceProfiles

        for (i, reqI) in requirementList.enumerated() {
            for j in (i + 1) ..< requirementList.count {
                let reqJ = requirementList[j]
                if !(reqI.acceptableDeviceTypes.intersection(reqJ.acceptableDeviceTypes).isEmpty) {
                    throw PhysDataError.illegalArgumentException("The required device types are not disjoint")
                }
            }
        }
        // The device types are disjoint now
        var result: [String: DeviceRequirement] = [:] // [DeviceType: DeviceRequirement]
        for deviceRequirement in requirementList {
            for i in stride(from: profiles.endIndex, through: 0, by: -1) {
                let deviceType = profiles[i].deviceType.rawValue
                if deviceRequirement.acceptableDeviceTypes.contains(deviceType) {
                    result[deviceType] = deviceRequirement
                    profiles.remove(at: i)
                }
            }
        }
        if result.count != requirementList.count {
            return nil
        }
        return result
    }
}
