import Foundation

public protocol DeviceType {
    var rawValue: String { get }
}

public extension DeviceType where Self: Hashable {
    func isEqualTo(_ other: DeviceType) -> Bool {
        guard let otherConcreteType = other as? Self else {
            return false
        }
        return self == otherConcreteType
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

public func == (lhs: DeviceType, rhs: DeviceType) -> Bool {
    lhs.rawValue == rhs.rawValue
}

public func != (lhs: DeviceType, rhs: DeviceType) -> Bool {
    lhs.rawValue != rhs.rawValue
}

// MARK: - Inner Class of DeviceType

// public extension DeviceType {

// MARK: - Left

public enum DeviceType_Left: String, DeviceType {
    case WRIST_BAND = "left_wrist_band"
    case THIGH_BAND = "left_thigh_band"
    case ANKLE_BAND = "left_ankle_band"
}

// MARK: - Right

public enum DeviceType_Right: String, DeviceType {
    case WRIST_BAND = "right_wrist_band"
    case THIGH_BAND = "right_thigh_band"
    case ANKLE_BAND = "right_ankle_band"
}

// MARK: - Unoriented

public enum DeviceType_Unoriented: String, DeviceType {
    case WAIST_BELT = "unoriented_waist_belt"
    case CHEST_BELT = "unoriented_chest_belt"
    case BIKE_CRANK_TRACKER = "unoriented_bike_crank_tracker"
    case FLEXCYCLE_RESISTANCE_KNOB_SENSOR = "unoriented_flexcycle_resistance_knob_sensor"
    case FLEXCYCLE_SENSOR = "unoriented_flexcycle_sensor"
    case KETTLEBELL = "unoriented_kettlebell"
}

extension DeviceType_Left: Equatable {
    public static func == (lhs: DeviceType_Left, rhs: DeviceType) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    public static func == (lhs: DeviceType, rhs: DeviceType_Left) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    public static func != (lhs: DeviceType_Left, rhs: DeviceType) -> Bool {
        lhs.rawValue != rhs.rawValue
    }

    public static func != (lhs: DeviceType, rhs: DeviceType_Left) -> Bool {
        lhs.rawValue != rhs.rawValue
    }
}

extension DeviceType_Left: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension DeviceType_Right: Equatable {
    public static func == (lhs: DeviceType_Right, rhs: DeviceType) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    public static func == (lhs: DeviceType, rhs: DeviceType_Right) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    public static func != (lhs: DeviceType_Right, rhs: DeviceType) -> Bool {
        lhs.rawValue != rhs.rawValue
    }

    public static func != (lhs: DeviceType, rhs: DeviceType_Right) -> Bool {
        lhs.rawValue != rhs.rawValue
    }
}

extension DeviceType_Right: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

extension DeviceType_Unoriented: Equatable {
    public static func == (lhs: DeviceType_Unoriented, rhs: DeviceType) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    public static func == (lhs: DeviceType, rhs: DeviceType_Unoriented) -> Bool {
        lhs.rawValue == rhs.rawValue
    }

    public static func != (lhs: DeviceType_Unoriented, rhs: DeviceType) -> Bool {
        lhs.rawValue != rhs.rawValue
    }

    public static func != (lhs: DeviceType, rhs: DeviceType_Unoriented) -> Bool {
        lhs.rawValue != rhs.rawValue
    }
}

extension DeviceType_Unoriented: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

// MARK: - Helper

public enum DeviceType_Helper {
    /// decodeFromReadableString()
    /// - Parameters:
    ///   - readableDeviceTypeString:
    /// - Returns: DeviceType
    public static func decodeFromReadableString(readableDeviceTypeString: String) -> DeviceType {
        if let left = DeviceType_Left(rawValue: readableDeviceTypeString) {
            return left
        } else if let right = DeviceType_Right(rawValue: readableDeviceTypeString) {
            return right
        } else if let unoriented = DeviceType_Unoriented(rawValue: readableDeviceTypeString) {
            return unoriented
        }
        // default
        return DeviceType_Left.WRIST_BAND
    }

    /// encodeToReadableString()
    /// - Parameters:
    ///   - deviceType:
    /// - Returns: String
    public static func encodeToReadableString(deviceType: DeviceType) -> String {
        deviceType.rawValue
    }
}
