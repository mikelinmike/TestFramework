import Foundation
import PhysData
import RxSwift

open class FitnessDevice {
    public var brand: Brand
    public var id: String
    public var canUnpair: Bool
    public var mConnectionStateSubject: BehaviorSubject<FitnessDevice.ConnectionState> = BehaviorSubject(value: FitnessDevice.ConnectionState.disconnected)
    public var connectionState: FitnessDevice.ConnectionState {
        (try? mConnectionStateSubject.value()) ?? FitnessDevice.ConnectionState.disconnected
    }

    public var mDeviceFieldSubject: PublishSubject<FitnessDevice.DeviceField> = PublishSubject()
    public var deviceType: DeviceType = DeviceType_Left.WRIST_BAND

    private var batteryValue: FitnessDevice.DeviceField?
    public var battery: FitnessDevice.DeviceField? {
        get {
            batteryValue
        }
        set {
            if let value = newValue {
                batteryValue = value
                mDeviceFieldSubject.onNext(value)
            }
        }
    }

    public var deviceProfile: DeviceProfile {
        DeviceProfile(deviceType: deviceType, sensorSupport: realtimeSensor.sensorSupport)
    }

    open var brandModel: String {
        fatalError("not been impl")
    }

    open var thumbnailImage: UIImage? {
        fatalError("not been impl")
    }

    open var realtimeSensor: RealtimeSensor {
        fatalError("not been impl")
    }

    /// init()

    public init(brand: Brand, id: String, canUnpair: Bool) {
        self.brand = brand
        self.id = id
        self.canUnpair = canUnpair
    }

    /// observeConnectionState()
    /// - Returns: Observable<FitnessDevice.ConnectionState>
    public func observeConnectionState() -> Observable<FitnessDevice.ConnectionState> {
        mConnectionStateSubject.distinctUntilChanged().observeOn(MainScheduler.instance)
    }

    /// hasDeviceField()
    /// - Parameters:
    ///   - fieldName:
    /// - Returns: Bool
    open func hasDeviceField(fieldName: FitnessDevice.DeviceField.FieldName) -> Bool {
        fatalError("not been impl")
    }

    /// observeDeviceField()
    /// - Parameters:
    ///   - vararg fieldNames:
    /// - Returns: Observable<DeviceField>
    public func observeDeviceField(fieldNames: FitnessDevice.DeviceField.FieldName...) -> Observable<FitnessDevice.DeviceField> {
        let fieldCopy = fieldNames.filter { hasDeviceField(fieldName: $0) }
        return mDeviceFieldSubject.filter {
            fieldCopy.contains($0.fieldName)
        }.observeOn(MainScheduler.instance)
    }

    /// hasDeviceField()
    /// - Parameters:
    ///   - fieldName:
    /// - Returns: Void
    open func fetchDeviceField(fieldName: DeviceField.FieldName) {
        fatalError("not been impl")
    }

    /// release()
    /// - Returns: Completable
    open func release() -> Completable {
        Completable.create { [self] observer in
            mConnectionStateSubject.onNext(FitnessDevice.ConnectionState.unpair)
            mConnectionStateSubject.onCompleted()
            mDeviceFieldSubject.onCompleted()
            realtimeSensor.release()

            observer(.completed)
            return Disposables.create()
        }
    }

    /// configureRealtimeSensor()
    /// - Parameters:
    ///   - deviceRequirement:
    /// - Returns: Completable
    public func configureRealtimeSensor(deviceRequirement: DeviceRequirement) -> Completable {
        if !(deviceRequirement.acceptableDeviceTypes.contains(deviceType.rawValue)) {
            return Completable.error(FitnessDeviceError.illegalArgumentException("Device type $\(deviceType) is not compatible to this requirement"))
        }
        return realtimeSensor.configure(sensorRequirement: deviceRequirement.sensorRequirement)
    }
}

extension FitnessDevice: Equatable {
    public static func == (lhs: FitnessDevice, rhs: FitnessDevice) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

// MARK: - Inner Class of FitnessDevice

public extension FitnessDevice {
    // MARK: - DeviceField

    enum DeviceField: Hashable {
        case battery(batteryPercentage: Int)
        case signalStrength(strength: Int)
        case firmwareVersion(version: String)
        case userIdentifier(identifier: String)
        case uuid(uuid: String)
        // The colorHex is in #RRGGBB hex digits format
        case color(colorHex: String)

        public var fieldName: FieldName {
            switch self {
            case .battery:
                return FitnessDevice.DeviceField.FieldName.battery
            case .signalStrength:
                return FitnessDevice.DeviceField.FieldName.signalStrength
            case .firmwareVersion:
                return FitnessDevice.DeviceField.FieldName.firmwareVersion
            case .userIdentifier:
                return FitnessDevice.DeviceField.FieldName.userIdentifier
            case .uuid:
                return FitnessDevice.DeviceField.FieldName.userIdentifier
            case .color:
                return FitnessDevice.DeviceField.FieldName.userIdentifier
            }
        }

        public func parsedColor() throws -> Int {
            if case let .color(colorHex) = self {
                if colorHex.starts(with: "#"),
                   colorHex.count == 7
                {
                    let hex = String(colorHex[colorHex.index(after: colorHex.startIndex)...])
                    if let colorRgb = Int(hex, radix: 16) {
                        return colorRgb
                    }
                }
            }
            throw FitnessDeviceError.illegalArgumentException("Unknown color")
        }

        public func toString() -> String {
            switch self {
            case let .battery(batteryPercentage):
                return "\(batteryPercentage)%"
            case let .signalStrength(strength):
                return String(strength)
            case let .firmwareVersion(version):
                return version
            case let .userIdentifier(identifier):
                return identifier
            case let .uuid(uuid):
                return uuid
            case let .color(colorHex):
                return colorHex
            }
        }
    }

    // MARK: - ConnectionState

    enum ConnectionState {
        case connecting
        case connected
        case disconnected
        case unpair
    }
}

// MARK: - Inner Class of FitnessDevice.DeviceField

public extension FitnessDevice.DeviceField {
    // MARK: - DeviceField

    enum FieldName {
        case battery
        case signalStrength
        case userIdentifier
        case firmwareVersion
    }
}
