import Foundation
import RxSwift

public protocol FitnessDeviceManager {
    /// pairExploredDevice()
    /// - Parameters:
    ///   - exploredDeviceInfo:
    /// - Returns: Single<FitnessDevice>
    func pairExploredDevice(exploredDeviceInfo: ExploredDeviceInfo) -> Single<FitnessDevice>

    /// unpairFitnessDevice()
    /// - Parameters:
    ///   - fitnessDevice:
    /// - Returns: Completable
    func unpairFitnessDevice(fitnessDevice: FitnessDevice) -> Completable

    /// unpairAllFitnessDevices()
    /// - Returns: Completable
    func unpairAllFitnessDevices() -> Completable

    /// getFitnessDevice()
    /// - Parameters:
    ///   - id:
    /// - Returns: FitnessDevice?
    func getFitnessDevice(id: String) -> FitnessDevice?

    /// containsFitnessDevice()
    /// - Parameters:
    ///   - id:
    /// - Returns: Bool
    func containsFitnessDevice(id: String) -> Bool

    /// getFitnessDevices()
    /// - Parameters:
    ///   - connectedOnly:
    /// - Returns: [FitnessDevice]
    func getFitnessDevices(connectedOnly: Bool) -> [FitnessDevice]
}

private var sThirdPartyManagers: [Brand: FitnessDeviceManager] = [:]
private var sUniversalManager: UniversalManager?

public enum UniversalFitnessDeviceManager {
    public static var universalManager: FitnessDeviceManager {
        if sUniversalManager == nil {
            sUniversalManager = UniversalManager()
        }
        return sUniversalManager!
    }

    /// registerThirdPartyManager()
    /// - Parameters:
    ///   - brand:
    ///   - fitnessDeviceManager:
    /// - Returns: Void
    public static func registerThirdPartyManager(brand: Brand, fitnessDeviceManager: FitnessDeviceManager) {
        sThirdPartyManagers[brand] = fitnessDeviceManager
    }
}

private class UniversalManager: FitnessDeviceManager {
    func pairExploredDevice(exploredDeviceInfo: ExploredDeviceInfo) -> Single<FitnessDevice> {
        sThirdPartyManagers[exploredDeviceInfo.brand]?.pairExploredDevice(exploredDeviceInfo: exploredDeviceInfo) ??
            Single.error(FitnessDeviceError.illegalArgumentException("\(exploredDeviceInfo.brand.name) is not exist"))
    }

    func unpairFitnessDevice(fitnessDevice: FitnessDevice) -> Completable {
        sThirdPartyManagers[fitnessDevice.brand]?.unpairFitnessDevice(fitnessDevice: fitnessDevice)
            ?? Completable.error(FitnessDeviceError.illegalArgumentException("\(fitnessDevice.brand.name) is not exist"))
    }

    func unpairAllFitnessDevices() -> Completable {
        Completable.merge(sThirdPartyManagers.values.map { $0.unpairAllFitnessDevices() })
    }

    func getFitnessDevice(id: String) -> FitnessDevice? {
        sThirdPartyManagers.values.first { $0.containsFitnessDevice(id: id) }?.getFitnessDevice(id: id)
    }

    func containsFitnessDevice(id: String) -> Bool {
        sThirdPartyManagers.values.contains(where: { $0.containsFitnessDevice(id: id) })
    }

    func getFitnessDevices(connectedOnly: Bool) -> [FitnessDevice] {
        sThirdPartyManagers.values.map { $0.getFitnessDevices(connectedOnly: connectedOnly) }.flatMap { $0 }
    }
}
