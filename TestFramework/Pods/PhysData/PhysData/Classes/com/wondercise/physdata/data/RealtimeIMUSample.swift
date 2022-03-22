import Foundation

public class RealtimeIMUSample: IMUSample {
    public let timestampMilliseconds: Int64

    /// init()
    /// - Parameters:
    ///   - timestampMs:
    ///   - imuSample:

    public init(timestampMs: Int64, imuSample: [[Double]]) {
        timestampMilliseconds = timestampMs
        super.init(imuSample: imuSample)
    }

    /// init()
    /// - Parameters:
    ///   - timestampMs:
    ///   - acceleration:
    ///   - angularVelocity:
    ///   - magneticField:

    public init(timestampMs: Int64, acceleration: [Double], angularVelocity: [Double]? = nil, magneticField: [Double]? = nil) {
        // TODO: UML codegen
        timestampMilliseconds = timestampMs
        super.init(acceleration: acceleration, angularVelocity: angularVelocity, magneticField: magneticField)
    }

    /// clone()
    /// - Returns: RealtimeIMUSample
    override public func clone() -> RealtimeIMUSample {
        RealtimeIMUSample(timestampMs: timestampMilliseconds, imuSample: super.clone().imuSample)
    }
}
