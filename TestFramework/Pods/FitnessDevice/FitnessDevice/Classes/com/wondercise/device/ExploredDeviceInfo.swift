import Foundation
import RxSwift

open class ExploredDeviceInfo {
    var brand: Brand
    open var thumbnailImage: UIImage? {
        fatalError("not been impl")
    }

    open var brandModel: String {
        fatalError("not been impl")
    }

    open var identifier: String {
        fatalError("not been impl")
    }

    open var firmwareVersion: String? {
        fatalError("not been impl")
    }

    open var reachability: ExploredDeviceInfo_Reachability {
        fatalError("not been impl")
    }

    /// init()
    /// - Parameters:
    ///   - brand:

    public init(brand: Brand) {
        self.brand = brand
    }
}

extension ExploredDeviceInfo: Equatable {
    public static func == (lhs: ExploredDeviceInfo, rhs: ExploredDeviceInfo) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

// MARK: - Inner Class of ExploredDeviceInfo

// MARK: - Reachability

public enum ExploredDeviceInfo_Reachability {
    case nearby
    case rssi(signalStrength: Int)
}
