import Foundation
import RxSwift

public protocol HasFirmwareVersion {
    var firmwareVersion: FitnessDevice.DeviceField { get }
}
