import Foundation
import PhysData
import RxSwift

public class XYAxisSwapper: AbstractHasNextPipe {}

// MARK: - ProcessPipe

extension XYAxisSwapper: ProcessPipe {
    public func process(realtimeIMUSample: RealtimeIMUSample) {
        if let mProcessPipe = mProcessPipe {
            let imuArray = realtimeIMUSample.imuSample

            for var measurement in imuArray { // inplace modification
                let tmp = measurement[0]
                measurement[0] = measurement[1]
                measurement[1] = tmp
            }
            realtimeIMUSample.imuSample = imuArray
            mProcessPipe.process(realtimeIMUSample: realtimeIMUSample)
        }
    }
}
