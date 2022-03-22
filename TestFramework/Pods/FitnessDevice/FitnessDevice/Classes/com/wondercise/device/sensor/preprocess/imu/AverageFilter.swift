import Foundation
import RxSwift

public class AverageFilter {
    private let mSize: Int
    private var mRatio: [Float]
    private var mWindow: [Double]
    private var mCount = 0

    public static var DEFAULT_FILTER_SIZE = 5

    /// init()
    public convenience init() {
        self.init(filterSize: AverageFilter.DEFAULT_FILTER_SIZE)
    }

    /// init()
    /// - Parameters:
    ///   - filterSize:

    public init(filterSize: Int) {
        mSize = filterSize
        mRatio = [Float](repeating: 0, count: filterSize)
        mWindow = [Double](repeating: 0, count: filterSize)

        let denominator = Float(mSize) * (Float(mSize + 1) / 2.0)
        for i in 0 ..< mSize {
            mRatio[i] = Float(mSize - i) / denominator
        }
    }

    /// filter()
    /// - Parameters:
    ///   - value:
    /// - Returns: Double
    public func filter(value: Double) -> Double {
        mWindow[mCount % mSize] = value
        var average = 0.0
        if mCount < mSize - 1 {
            let denominator: Float = (Float(mCount) + 1) * (Float(mCount) + 2) / 2.0
            for i in 0 ..< mCount {
                average += mWindow[i] * Double(i + 1) / Double(denominator)
            }
        } else {
            for i in 0 ..< mSize {
                average += mWindow[(mCount - i) % mSize] * Double(mRatio[i])
            }
        }
        mCount += 1
        return average
    }
}
