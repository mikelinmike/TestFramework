import Foundation

open class IMUSample {
    public var imuSample: [[Double]]
    public var axisNumber: Int {
        imuSample.count * 3
    }

    public var accelerationOrZeros: [Double] {
        imuSample[0]
    }

    public var angularVelocityOrZeros: [Double] {
        if imuSample.count >= 2 {
            return imuSample[1]
        } else {
            return IMUSample.DUMMY_READING
        }
    }

    public var magneticFieldOrZeros: [Double] {
        if imuSample.count == 3 {
            return imuSample[2]
        } else {
            return IMUSample.DUMMY_READING
        }
    }

    private static let DUMMY_READING: [Double] = [0.0, 0.0, 0.0]

    /// init()
    /// - Parameters:
    ///   - imuSample:

    public init(imuSample: [[Double]]) {
        self.imuSample = imuSample
    }

    /// init()
    /// - Parameters:
    ///   - acceleration:
    ///   - angularVelocity:
    ///   - magneticField:

    public init(acceleration: [Double], angularVelocity: [Double]? = nil, magneticField: [Double]? = nil) {
        if let angularVelocity = angularVelocity {
            if let magneticField = magneticField {
                imuSample = [acceleration, angularVelocity, magneticField]
            } else {
                imuSample = [acceleration, angularVelocity]
            }
        } else {
            imuSample = [acceleration]
        }
    }

    /// clone()
    /// - Returns: IMUSample
    public func clone() -> IMUSample {
        IMUSample(imuSample: imuSample.map({ $0 }))
    }
}
