import Foundation
import PhysData
import RxSwift

public class LeftToRightHandedCoordinateSystemConverter: AbstractHasNextPipe {
    private let mCoordinateSystems: [CoordinateSystem]

    public init(mCoordinateSystems: [CoordinateSystem]) {
        self.mCoordinateSystems = mCoordinateSystems
        super.init()
    }
}

// MARK: - ProcessPipe

extension LeftToRightHandedCoordinateSystemConverter: ProcessPipe {
    public func process(realtimeIMUSample: RealtimeIMUSample) {
        if let mProcessPipe = mProcessPipe {
            for i in realtimeIMUSample.imuSample.indices { // inplace modification
                realtimeIMUSample.imuSample[i] = mCoordinateSystems[i].convertLeftToRightHanded(sample: realtimeIMUSample.imuSample[i])
            }
            mProcessPipe.process(realtimeIMUSample: realtimeIMUSample)
        }
    }
}

// MARK: - Inner Class of LeftToRightHandedCoordinateSystemConverter

extension LeftToRightHandedCoordinateSystemConverter {
    // MARK: - CoordinateSystem

    public enum CoordinateSystem {
        case acceleration
        case angularVelocity
        case magneticField

        var coeffs: [Double] {
            switch self {
            case .acceleration:
                return [1.0, -1.0, 1.0]
            case .angularVelocity:
                return [-1.0, 1.0, -1.0]
            case .magneticField:
                return [1.0, -1.0, 1.0]
            }
        }

        func convertLeftToRightHanded(sample: [Double]) -> [Double] {
            zip(coeffs, sample).map { c, s in c * s }
        }
    }
}
