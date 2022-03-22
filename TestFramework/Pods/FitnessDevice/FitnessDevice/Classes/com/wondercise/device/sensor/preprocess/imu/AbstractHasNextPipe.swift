import Foundation
import RxSwift

open class AbstractHasNextPipe: HasNextPipe {
    public var mProcessPipe: ProcessPipe?

    public init() {}
    
    public func next<I>(nextPipe: I) -> I where I: ProcessPipe {
        mProcessPipe = nextPipe
        return nextPipe
    }

    open func reset() {
        mProcessPipe?.reset()
    }
}
