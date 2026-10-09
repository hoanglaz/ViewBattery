import Foundation
import IOKit
import IOKit.ps

public class BatteryService {
    public static let shared = BatteryService()

    private init() {}

    public func fetchBatteryInfo() -> BatteryInfo {
        autoreleasepool {
            var info = BatteryInfo()

            // 1. Đọc thông tin từ AppleSmartBattery qua IORegistry
            var iterator: io_iterator_t = 0
            let matching = IOServiceMatching("AppleSmartBattery")
            let result = IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator)

            if result == kIOReturnSuccess {
                let service = IOIteratorNext(iterator)
                if service != 0 {
                    var props: Unmanaged<CFMutableDictionary>?
                    if IORegistryEntryCreateCFProperties(service, &props, kCFAllocatorDefault, 0) == kIOReturnSuccess,
                       let dict = props?.takeRetainedValue() as? [String: Any] {
                        parseBatteryDictionary(dict, into: &info)
                    }
                    IOObjectRelease(service)
                }
                IOObjectRelease(iterator)
            }

            // 2. Bổ sung thông tin từ IOPS (IOPowerSources)
            fillPowerSourceDetails(into: &info)

            return info
        }
    }

    private func parseBatteryDictionary(_ dict: [String: Any], into info: inout BatteryInfo) {
        // Trạng thái cắm nguồn & sạc
        info.isPluggedIn = (dict["ExternalConnected"] as? Bool) ?? (dict["ExternalConnected"] as? Int == 1)
        info.isCharging = (dict["IsCharging"] as? Bool) ?? (dict["IsCharging"] as? Int == 1)
        info.isFullyCharged = (dict["FullyCharged"] as? Bool) ?? (dict["FullyCharged"] as? Int == 1)

        // Dung lượng pin & %
        if let currentCap = dict["CurrentCapacity"] as? Int {
            info.currentCapacity = currentCap
        }
        if let maxCap = dict["MaxCapacity"] as? Int {
            info.maxCapacity = maxCap
        }
        if info.maxCapacity > 0 {
            info.percentage = min(100, max(0, Int((Double(info.currentCapacity) / Double(info.maxCapacity)) * 100.0)))
        }

        // Chu kỳ sạc & Dung lượng thiết kế
        if let cycle = dict["CycleCount"] as? Int {
            info.cycleCount = cycle
        }
        if let design = dict["DesignCapacity"] as? Int {
            info.designCapacity = design
        }

        // Điện áp & Dòng điện pin
        let rawVoltage = (dict["Voltage"] as? Double) ?? Double(dict["Voltage"] as? Int ?? 0)
        info.batteryVoltage = rawVoltage / 1000.0 // mV sang V

        // Amperage là signed integer (âm khi xả, dương khi sạc)
        let rawAmperage: Double
        if let amp = dict["Amperage"] as? Int {
            rawAmperage = Double(amp)
        } else if let amp = dict["Amperage"] as? Double {
            rawAmperage = amp
        } else if let amp = dict["InstantAmperage"] as? Int {
            rawAmperage = Double(amp)
        } else {
            rawAmperage = 0.0
        }
        info.batteryAmperage = rawAmperage / 1000.0 // mA sang A

        // Công suất vào/ra pin (W = V * A)
        info.batteryPowerWatts = info.batteryVoltage * info.batteryAmperage

        // Nhiệt độ (giá trị trong registry thường nhân 100, ví dụ 3019 = 30.19°C)
        if let rawTemp = dict["Temperature"] as? Int {
            info.temperatureCelsius = Double(rawTemp) / 100.0
        } else if let rawTemp = dict["VirtualTemperature"] as? Int {
            info.temperatureCelsius = Double(rawTemp) / 100.0
        }

        // 3. Adapter Details (Thông tin củ sạc định danh)
        if let adapter = dict["AdapterDetails"] as? [String: Any] {
            if let watts = adapter["Watts"] as? Double {
                info.adapterWatts = watts
            } else if let watts = adapter["Watts"] as? Int {
                info.adapterWatts = Double(watts)
            }

            if let volt = adapter["AdapterVoltage"] as? Double {
                info.adapterVoltage = volt / 1000.0
            } else if let volt = adapter["AdapterVoltage"] as? Int {
                info.adapterVoltage = Double(volt) / 1000.0
            }

            if let curr = adapter["Current"] as? Double {
                info.adapterCurrent = curr / 1000.0
            } else if let curr = adapter["Current"] as? Int {
                info.adapterCurrent = Double(curr) / 1000.0
            }

            info.adapterDescription = adapter["Description"] as? String
        }

        // 4. Power Telemetry Data (Apple Silicon realtime input power)
        if let telemetry = dict["PowerTelemetryData"] as? [String: Any] {
            if let sysPowerIn = telemetry["SystemPowerIn"] as? Double {
                info.systemPowerInWatts = sysPowerIn / 1000.0 // mW sang W
            } else if let sysPowerIn = telemetry["SystemPowerIn"] as? Int {
                info.systemPowerInWatts = Double(sysPowerIn) / 1000.0
            }

            if let sysLoad = telemetry["SystemLoad"] as? Double {
                info.systemLoadWatts = sysLoad / 1000.0
            } else if let sysLoad = telemetry["SystemLoad"] as? Int {
                info.systemLoadWatts = Double(sysLoad) / 1000.0
            }
        }

        // 5. Kiểm tra trường hợp đặc biệt: BatteryData lồng bên trong
        if let batteryData = dict["BatteryData"] as? [String: Any] {
            if info.cycleCount == nil, let cycle = batteryData["CycleCount"] as? Int {
                info.cycleCount = cycle
            }
            if info.designCapacity == nil, let design = batteryData["DesignCapacity"] as? Int {
                info.designCapacity = design
            }
            if info.percentage == 0, let soc = batteryData["StateOfCharge"] as? Int {
                info.percentage = soc
            }
        }
    }

    private func fillPowerSourceDetails(into info: inout BatteryInfo) {
        guard let blob = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else { return }
        guard let sources = IOPSCopyPowerSourcesList(blob)?.takeRetainedValue() as? [CFTypeRef] else { return }

        for source in sources {
            guard let desc = IOPSGetPowerSourceDescription(blob, source)?.takeUnretainedValue() as? [String: Any] else {
                continue
            }

            if let cond = desc[kIOPSBatteryHealthConditionKey as String] as? String, !cond.isEmpty {
                info.condition = cond
            } else if let health = desc[kIOPSBatteryHealthKey as String] as? String {
                info.condition = health
            }

            if info.percentage == 0, let cap = desc[kIOPSCurrentCapacityKey as String] as? Int {
                info.percentage = cap
            }
        }
    }
}
