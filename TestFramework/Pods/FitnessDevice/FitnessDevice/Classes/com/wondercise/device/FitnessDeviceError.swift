import Foundation

public enum FitnessDeviceError: Error {
    case illegalArgumentException(_ description: String)
    case illegalStateException(_ description: String)
}
