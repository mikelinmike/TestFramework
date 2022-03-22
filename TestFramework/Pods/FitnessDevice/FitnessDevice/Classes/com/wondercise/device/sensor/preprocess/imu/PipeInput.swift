import Foundation
import RxSwift

public protocol PipeInput: HasNextPipe {

    /// processRaw()
    /// - Parameters:
    ///   - timestampMs: 
    ///   - accelerationRawSample: 
    /// - Returns: Void
    func processRaw(timestampMs: Int64, accelerationRawSample: [Int])  

    /// processRaw()
    /// - Parameters:
    ///   - timestampMs: 
    ///   - accelerationRawSample: 
    ///   - angularVelocityRawSample: 
    /// - Returns: Void
    func processRaw(timestampMs: Int64, accelerationRawSample: [Int], angularVelocityRawSample: [Int])  

    /// processRaw()
    /// - Parameters:
    ///   - timestampMs: 
    ///   - accelerationRawSample: 
    ///   - angularVelocityRawSample: 
    ///   - magneticFieldRawSample: 
    /// - Returns: Void
    func processRaw(timestampMs: Int64, accelerationRawSample: [Int], angularVelocityRawSample: [Int], magneticFieldRawSample: [Int])  
}
