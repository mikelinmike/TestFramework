import Foundation
import RxSwift

public struct Brand: Hashable {
    public var name: String
    public var companionAppVersion: String?
    public var moduleId: String

    public init(name: String,
                companionAppVersion: String? = nil,
                moduleId: String)
    {
        self.name = name
        self.companionAppVersion = companionAppVersion
        self.moduleId = moduleId
    }
}
