import Foundation
import RxSwift

open class AbstractDeviceExplorer: DeviceExplorer {
    public let mSubject: PublishSubject<Result<ExploredDeviceInfo, Error>> = PublishSubject()
    private var mExploredStarted = false
    private let lock = NSLock()

    public init() {}

    public func startExploreDevice() {
        lock.lock()
        defer { lock.unlock() }
        if mExploredStarted {
            return
        }
        startExploreDeviceImpl()
        mExploredStarted = true
    }

    public func observeExploredDeviceInfo() -> Observable<Result<ExploredDeviceInfo, Error>> {
        mSubject.observeOn(MainScheduler.instance)
    }

    public func stopExploreDevice() {
        lock.lock()
        defer { lock.unlock() }
        if !mExploredStarted {
            return
        }
        stopExploreDeviceImpl()
        mExploredStarted = false
    }

    /// startExploreDeviceImpl()
    /// - Returns: Void
    open func startExploreDeviceImpl() {
        fatalError("not been impl")
    }

    /// stopExploreDeviceImpl()
    /// - Returns: Void
    open func stopExploreDeviceImpl() {
        fatalError("not been impl")
    }
}
