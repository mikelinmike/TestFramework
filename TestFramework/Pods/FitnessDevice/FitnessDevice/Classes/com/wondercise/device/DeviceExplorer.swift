import Foundation
import RxSwift

private var sThirdPartyExplorers: [DeviceExplorer] = []
private var sUniversalExplorer: UniversalExplorer?

public protocol DeviceExplorer {

    /// startExploreDevice()
    /// - Returns: Void
    func startExploreDevice()

    /// observeExploredDeviceInfo()
    /// - Returns: Observable<Result<ExploredDeviceInfo, Error>>
    func observeExploredDeviceInfo() -> Observable<Result<ExploredDeviceInfo, Error>>

    /// stopExploreDevice()
    /// - Returns: Void
    func stopExploreDevice()
}

public enum UniversalDeviceExplorer {
    public static var universalExplorer: DeviceExplorer {
        if sUniversalExplorer == nil {
            sUniversalExplorer = UniversalExplorer()
        }
        return sUniversalExplorer!
    }

    /// registerDeviceExplorer()
    /// - Parameters:
    ///   - deviceExplorer:
    /// - Returns: Void
    public static func registerDeviceExplorer(deviceExplorer: DeviceExplorer) {
        sThirdPartyExplorers.append(deviceExplorer)
    }
}

private class UniversalExplorer: DeviceExplorer {
    private let mThirdPartyExplorers = sThirdPartyExplorers

    func startExploreDevice() {
        mThirdPartyExplorers.forEach { $0.startExploreDevice() }
    }

    func observeExploredDeviceInfo() -> Observable<Result<ExploredDeviceInfo, Error>> {
        Observable.merge(mThirdPartyExplorers.map { $0.observeExploredDeviceInfo() })
    }

    func stopExploreDevice() {
        mThirdPartyExplorers.forEach { $0.stopExploreDevice() }
    }
}
