import Foundation

public enum RealtimeHeartMonitorSample {
    case realtimeHeartRateSample(timestampMilliseconds: Int64, heartRate: Int)
    case realtimeHeartRateVariabilitySample(timestampMilliseconds: Int64, heatRateVariability: Int)
}
