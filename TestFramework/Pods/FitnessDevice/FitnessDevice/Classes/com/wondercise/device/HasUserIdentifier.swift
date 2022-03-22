import Foundation
import RxSwift

public protocol HasUserIdentifier {
    var userIdentifier: FitnessDevice.DeviceField? { get }
}
