import Foundation
import PhysData
import RxSwift

private let STARTING_TIMEOUT_IN_SECONDS = 7
private let STARTED_TIMEOUT_IN_SECONDS = 3

open class RealtimeSensor {
    public var realtimeDataListener: RealtimeSensor_RealtimeDataListener?
    open var mTransmissionStateMachine: RealtimeSensor.DataTransmissionStateMachine {
        fatalError("not been impl")
    }

    open var sensorSupport: SensorSupport {
        fatalError("not been impl")
    }

    public init() {}

    /// startRealtimeData()
    /// - Returns: Void
    public func startRealtimeData() {
        mTransmissionStateMachine.emitEvent(transmissionEvent: RealtimeSensor.TransmissionEvent.startRealtimeData)
    }

    /// pauseRealtimeData()
    /// - Returns: Void
    public func pauseRealtimeData() {
        mTransmissionStateMachine.emitEvent(transmissionEvent: RealtimeSensor.TransmissionEvent.pauseRealtimeData)
    }

    /// stopRealtimeData()
    /// - Returns: Void
    public func stopRealtimeData() {
        mTransmissionStateMachine.emitEvent(transmissionEvent: RealtimeSensor.TransmissionEvent.stopRealtimeData)
    }

    /// observeRealtimeState()
    /// - Returns: Observable<RealtimeSensor.RealtimeState>
    public func observeRealtimeState() -> Observable<RealtimeSensor.RealtimeState> {
        mTransmissionStateMachine.observeRealtimeState()
    }

    /// release()
    /// - Returns: Void
    open func release() {
        mTransmissionStateMachine.release()
    }

    /// configureBegin()
    /// - Returns: Void
    open func configureBegin() {
        fatalError("not been impl")
    }

    /// configureEnd()
    /// - Returns: Completable
    open func configureEnd() -> Completable {
        fatalError("not been impl")
    }

    /// configure()
    /// - Parameters:
    ///   - sensorRequirement:
    /// - Returns: Completable
    func configure(sensorRequirement: SensorRequirement) -> Completable {
        if !sensorSupport.isSupport(sensorRequirement: sensorRequirement) {
            return Completable.error(FitnessDeviceError.illegalArgumentException("sensor support is not compatible to the requirement"))
        }
        configureBegin()
        let sensors = sensorRequirement.requiredSensors
        for sensor in sensors {
            switch sensor {
            case .imu:
                if let downcast = self as? IMUConfiguration {
                    try? downcast.configure(imu: sensor)
                }
            case .heartMonitorSensor:
                if let downcast = self as? HeartMonitorSensorConfiguration {
                    try? downcast.configure(heartMonitorSensor: sensor)
                }
            }
        }
        return configureEnd()
    }

    // MARK: - DataTransmissionStateMachine

    open class DataTransmissionStateMachine {
        public let connectionStateSubject: BehaviorSubject<FitnessDevice.ConnectionState>
        var mHeartbeatTimestamp: Int64 = 0 // AtomicLong
        public var isStarted: Bool {
            if case RealtimeSensor.RealtimeState.started = state {
                return true
            }
            return false
        }

        var mIsPaused = false
        private let mTransmissionEventSubject = PublishSubject<RealtimeSensor.TransmissionEvent>()
        private let mRealtimeStateSubject = BehaviorSubject<RealtimeSensor.RealtimeState>(value: RealtimeSensor.RealtimeState.initial)
        var state: RealtimeSensor.RealtimeState { try! mRealtimeStateSubject.value() }

        private let mStateEndProcedureMap: [RealtimeSensor.RealtimeState: (RealtimeSensor.DataTransmissionStateMachine) -> (RealtimeSensor.RealtimeState, RealtimeSensor.RealtimeState) -> Void]
        private let mStateStartProcedureMap: [RealtimeSensor.RealtimeState: (RealtimeSensor.DataTransmissionStateMachine) -> (RealtimeSensor.RealtimeState, RealtimeSensor.RealtimeState) -> Void]

        private var mStartingTimerDisposable: Disposable?
        private var mDataHeartbeatDisposable: Disposable?

        private var mConnectionStateDisposable: Disposable?
        private var mEventDisposable: Disposable?

        /// init()
        /// - Parameters:
        ///   - connectionStateSubject:

        public init(connectionStateSubject: BehaviorSubject<FitnessDevice.ConnectionState>) {
            self.connectionStateSubject = connectionStateSubject

            mStateEndProcedureMap = [
                RealtimeSensor.RealtimeState.initial: type(of: self).initialEnd,
                RealtimeSensor.RealtimeState.starting(cause: RealtimeSensor.RealtimeState.Cause.application): type(of: self).startingEnd,
                RealtimeSensor.RealtimeState.starting(cause: RealtimeSensor.RealtimeState.Cause.timeout): type(of: self).startingEnd,
                RealtimeSensor.RealtimeState.starting(cause: RealtimeSensor.RealtimeState.Cause.reconnected): type(of: self).startingEnd,
                RealtimeSensor.RealtimeState.started: type(of: self).startedEnd,
                RealtimeSensor.RealtimeState.paused: type(of: self).pausedEnd,
                RealtimeSensor.RealtimeState.recovering(cause: RealtimeSensor.RealtimeState.Cause.disconnected): type(of: self).recoveringEnd,
            ]

            mStateStartProcedureMap = [
                RealtimeSensor.RealtimeState.initial: type(of: self).initialBegin,
                RealtimeSensor.RealtimeState.starting(cause: RealtimeSensor.RealtimeState.Cause.application): type(of: self).startingBegin,
                RealtimeSensor.RealtimeState.starting(cause: RealtimeSensor.RealtimeState.Cause.timeout): type(of: self).startingBegin,
                RealtimeSensor.RealtimeState.starting(cause: RealtimeSensor.RealtimeState.Cause.reconnected): type(of: self).startingBegin,
                RealtimeSensor.RealtimeState.started: type(of: self).startedBegin,
                RealtimeSensor.RealtimeState.paused: type(of: self).pausedBegin,
                RealtimeSensor.RealtimeState.recovering(cause: RealtimeSensor.RealtimeState.Cause.disconnected): type(of: self).recoveringBegin,
            ]

            mConnectionStateDisposable = connectionStateSubject
                .observeOn(SerialDispatchQueueScheduler(internalSerialQueueName: "DataTransmissionStateMachine")) // The reason why we need to schedule the event on single, see startingBegin
                .subscribe(onNext: { [weak self] state in
                    guard let self = self else { return }
                    if case FitnessDevice.ConnectionState.connected = state {
                        self.emitEvent(transmissionEvent: RealtimeSensor.TransmissionEvent.didReconnected)
                    } else if case FitnessDevice.ConnectionState.disconnected = state {
                        self.emitEvent(transmissionEvent: RealtimeSensor.TransmissionEvent.didDisconnected)
                    }
                })

            mEventDisposable = mTransmissionEventSubject
                .subscribe(onNext: { [weak self] event in
                    guard let self = self else { return }
                    let previousState = try! self.mRealtimeStateSubject.value()
                    var nextState: RealtimeSensor.RealtimeState?
                    switch previousState {
                    case .initial:
                        switch event {
                        case .startRealtimeData:
                            nextState = .starting(cause: RealtimeSensor.RealtimeState.Cause.application)
                        default:
                            return
                        }
                    case let .starting(cause):
                        switch event {
                        case .stopRealtimeData:
                            nextState = .initial
                        case .didDataReady:
                            if self.mIsPaused {
                                nextState = .paused
                            } else {
                                nextState = .started
                            }
                        case .receiveNoData:
                            nextState = .starting(cause: RealtimeSensor.RealtimeState.Cause.timeout)
                        case .didDisconnected:
                            nextState = .recovering(cause: RealtimeSensor.RealtimeState.Cause.disconnected)
                        default:
                            return
                        }
                    case .started:
                        switch event {
                        case .pauseRealtimeData:
                            self.mIsPaused = true
                            nextState = .initial
                        case .stopRealtimeData:
                            nextState = .initial
                        case .receiveNoData:
                            nextState = .starting(cause: RealtimeSensor.RealtimeState.Cause.timeout)
                        case .didDisconnected:
                            nextState = .recovering(cause: RealtimeSensor.RealtimeState.Cause.disconnected)
                        default:
                            return
                        }
                    case .paused:
                        switch event {
                        case .startRealtimeData:
                            self.mIsPaused = false
                            nextState = .started
                        case .stopRealtimeData:
                            nextState = .initial
                        case .receiveNoData:
                            nextState = .starting(cause: RealtimeSensor.RealtimeState.Cause.timeout)
                        case .didDisconnected:
                            nextState = .recovering(cause: RealtimeSensor.RealtimeState.Cause.disconnected)
                        default:
                            return
                        }
                    case let .recovering(cause):
                        switch cause {
                        case .disconnected:
                            switch event {
                            case .didReconnected:
                                nextState = .starting(cause: RealtimeSensor.RealtimeState.Cause.reconnected)
                            case .stopRealtimeData:
                                nextState = .initial
                            default:
                                return
                            }
                        default:
                            return
                        }
                    }

                    if let nextState = nextState {
                        print("StateMachine", "state transit \(previousState) ==> \(nextState)")
                        self.mStateEndProcedureMap[previousState]?(self)(previousState, nextState)
                        self.mRealtimeStateSubject.onNext(nextState)
                        self.mStateStartProcedureMap[nextState]?(self)(nextState, previousState)
                    }
                })
        }

        /// dataReceived()
        /// - Returns: Void
        public func dataReceived() {
            mHeartbeatTimestamp = Int64(Date().timeIntervalSince1970 * 1000)
        }

        /// emitEvent()
        /// - Parameters:s
        ///   - transmissionEvent:
        /// - Returns: Void
        public func emitEvent(transmissionEvent: RealtimeSensor.TransmissionEvent) {
            mTransmissionEventSubject.onNext(transmissionEvent)
        }

        /// observeRealtimeState()
        /// - Returns: Observable<RealtimeSensor.RealtimeState>
        func observeRealtimeState() -> Observable<RealtimeSensor.RealtimeState> {
            mRealtimeStateSubject
        }

        /// release()
        /// - Returns: Void
        func release() {
            mStartingTimerDisposable?.dispose()
            mDataHeartbeatDisposable?.dispose()
            mRealtimeStateSubject.onCompleted()
            mConnectionStateDisposable?.dispose()
        }

        private func launchHeartbeatInterval() {
            mDataHeartbeatDisposable =
                Observable<Int>.interval(.seconds(STARTED_TIMEOUT_IN_SECONDS), scheduler: SerialDispatchQueueScheduler(internalSerialQueueName: "DataHeartbeat"))
                    .subscribe(onNext: { [weak self] _ in // The scheduling is not necessary but by convention and consistency
                        guard let self = self else { return }
                        if Int64(Date().timeIntervalSince1970 * 1000) - self.mHeartbeatTimestamp > STARTED_TIMEOUT_IN_SECONDS * 1000 {
                            self.emitEvent(transmissionEvent: RealtimeSensor.TransmissionEvent.receiveNoData)
                        }
                    })
        }

        /// initialBegin()
        /// - Parameters:
        ///   - currentState:
        ///   - previousState:
        /// - Returns: Void
        open func initialBegin(currentState: RealtimeSensor.RealtimeState, previousState: RealtimeSensor.RealtimeState) {
            // Note, stop transmission first
            mIsPaused = false
        }

        /// initialEnd()
        /// - Parameters:
        ///   - currentState:
        ///   - nextState:
        /// - Returns: Void
        open func initialEnd(currentState: RealtimeSensor.RealtimeState, nextState: RealtimeSensor.RealtimeState) {}

        /// startingBegin()
        /// - Parameters:
        ///   - currentState:
        ///   - previousState:
        /// - Returns: Void
        open func startingBegin(currentState: RealtimeSensor.RealtimeState, previousState: RealtimeSensor.RealtimeState) {
            // Note, start transmission first then set the timer
            mStartingTimerDisposable =

                Completable.empty().delay(.seconds(STARTED_TIMEOUT_IN_SECONDS), scheduler: SerialDispatchQueueScheduler(internalSerialQueueName: "DataHeartbeat"))
                .subscribe(onCompleted: { [weak self] in
                    guard let self = self else { return }
                    /* The reconnected event can intervene in the following two lines, which must check and emit atomically.
                     * Otherwise, the recovering state machine will wait until next reconnection while the device is actually connected.
                     * Therefore, we schedule connection related events on the single shared thread, to avoid this issue.
                     */

                    if case FitnessDevice.ConnectionState.connected = try! self.connectionStateSubject.value() {
                        self.emitEvent(transmissionEvent: RealtimeSensor.TransmissionEvent.didDisconnected)
                    } else {
                        self.emitEvent(transmissionEvent: RealtimeSensor.TransmissionEvent.receiveNoData)
                    }
                })
        }

        /// startingEnd()
        /// - Parameters:
        ///   - currentState:
        ///   - nextState:
        /// - Returns: Void
        open func startingEnd(currentState: RealtimeSensor.RealtimeState, nextState: RealtimeSensor.RealtimeState) {
            mStartingTimerDisposable?.dispose()
        }

        /// startedBegin()
        /// - Parameters:
        ///   - currentState:
        ///   - previousState:
        /// - Returns: Void
        open func startedBegin(currentState: RealtimeSensor.RealtimeState, previousState: RealtimeSensor.RealtimeState) {
            if case RealtimeSensor.RealtimeState.paused = previousState {
                return
            }
            launchHeartbeatInterval()
        }

        /// startedEnd()
        /// - Parameters:
        ///   - currentState:
        ///   - nextState:
        /// - Returns: Void
        open func startedEnd(currentState: RealtimeSensor.RealtimeState, nextState: RealtimeSensor.RealtimeState) {
            if case RealtimeSensor.RealtimeState.paused = nextState {
                return
            }
            mDataHeartbeatDisposable?.dispose()
        }

        /// pausedBegin()
        /// - Parameters:
        ///   - currentState:
        ///   - previousState:
        /// - Returns: Void
        open func pausedBegin(currentState: RealtimeSensor.RealtimeState, previousState: RealtimeSensor.RealtimeState) {
            if case RealtimeSensor.RealtimeState.started = previousState {
                return
            }
            launchHeartbeatInterval()
        }

        /// pausedEnd()
        /// - Parameters:
        ///   - currentState:
        ///   - nextState:
        /// - Returns: Void
        open func pausedEnd(currentState: RealtimeSensor.RealtimeState, nextState: RealtimeSensor.RealtimeState) {
            if case RealtimeSensor.RealtimeState.started = nextState {
                return
            }
            mDataHeartbeatDisposable?.dispose()
        }

        /// recoveringBegin()
        /// - Parameters:
        ///   - currentState:
        ///   - previousState:
        /// - Returns: Void
        open func recoveringBegin(currentState: RealtimeSensor.RealtimeState, previousState: RealtimeSensor.RealtimeState) {}

        /// recoveringEnd()
        /// - Parameters:
        ///   - currentState:
        ///   - nextState:
        /// - Returns: Void
        open func recoveringEnd(currentState: RealtimeSensor.RealtimeState, nextState: RealtimeSensor.RealtimeState) {}
    }
}

// MARK: - RealtimeDataListener

public protocol RealtimeSensor_RealtimeDataListener {
    /// onRealtimeSample()
    /// - Parameters:
    ///   - realtimeIMUSample:
    /// - Returns: Void
    func onRealtimeSample(realtimeIMUSample: RealtimeIMUSample)

    /// onRealtimeSample()
    /// - Parameters:
    ///   - realtimeHeartMonitorSample:
    /// - Returns: Void
    func onRealtimeSample(realtimeHeartMonitorSample: RealtimeHeartMonitorSample)
}

// MARK: - Inner Class of RealtimeSensor

public extension RealtimeSensor {
    // MARK: - RealtimeState

    enum RealtimeState: Hashable {
        case initial
        case starting(cause: RealtimeSensor.RealtimeState.Cause)
        case started
        case paused
        case recovering(cause: RealtimeSensor.RealtimeState.Cause)

        /// toString()
        /// - Returns: String
        func toString() -> String {
            switch self {
            case .initial:
                return "initial"
            case let .starting(cause):
                return "starting\(cause)"
            case .started:
                return "started"
            case .paused:
                return "paused"
            case let .recovering(cause):
                return "recovering\(cause)"
            }
        }
    }

    // MARK: - TransmissionEvent

    enum TransmissionEvent {
        case startRealtimeData
        case pauseRealtimeData
        case stopRealtimeData
        case didReconnected
        case didDataReady
        case receiveNoData
        case didDisconnected
    }
}

// MARK: - Inner Class of RealtimeSensor.RealtimeState

// MARK: - Cause

public extension RealtimeSensor.RealtimeState {
    enum Cause {
        case application
        case disconnected
        case reconnected
        case timeout
    }
}
