import Foundation

public enum MenuBarDisplayMode: String, CaseIterable, Identifiable {
    case livePower = "livePower"          // Công suất thực tế máy đang nhận (ví dụ: 10.6W hoặc 65W)
    case adapterPower = "adapterPower"    // Công suất định danh của củ sạc (ví dụ: 67W)
    case combined = "combined"            // Kết hợp (ví dụ: 10.6W / 67W)
    case batteryFlow = "batteryFlow"      // Công suất nạp / xả của cell pin (+/- W)

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .livePower: return "Công suất thực tế"
        case .adapterPower: return "Công suất củ sạc"
        case .combined: return "Cả hai (Thực tế / Sạc)"
        case .batteryFlow: return "Dòng nạp / xả pin"
        }
    }
}

public struct BatteryInfo: Equatable {
    // Trạng thái kết nối
    public var isPluggedIn: Bool
    public var isCharging: Bool
    public var isFullyCharged: Bool

    // Mức pin
    public var currentCapacity: Int
    public var maxCapacity: Int
    public var percentage: Int

    // Công suất (Watts)
    public var adapterWatts: Double?          // Watts danh định từ AdapterDetails (ví dụ: 67W)
    public var systemPowerInWatts: Double?     // Watts thực tế qua USB-C/MagSafe (từ PowerTelemetryData)
    public var systemLoadWatts: Double?        // Công suất tải toàn máy tiêu thụ
    public var batteryPowerWatts: Double       // Công suất dòng vào/ra pin (Voltage * Amperage / 1,000,000)

    // Điện áp & Dòng điện
    public var batteryVoltage: Double          // Volts (ví dụ: 12.4 V)
    public var batteryAmperage: Double         // Amps (dương khi nạp, âm khi xả)
    public var adapterVoltage: Double?         // Volts từ củ sạc (ví dụ: 20.0 V)
    public var adapterCurrent: Double?         // Amps từ củ sạc (ví dụ: 3.35 A)
    public var adapterDescription: String?     // Mô tả củ sạc (ví dụ: "pd charger", "Apple MagSafe")

    // Sức khoẻ pin
    public var cycleCount: Int?
    public var designCapacity: Int?
    public var temperatureCelsius: Double?
    public var condition: String?

    public init(
        isPluggedIn: Bool = false,
        isCharging: Bool = false,
        isFullyCharged: Bool = false,
        currentCapacity: Int = 0,
        maxCapacity: Int = 100,
        percentage: Int = 0,
        adapterWatts: Double? = nil,
        systemPowerInWatts: Double? = nil,
        systemLoadWatts: Double? = nil,
        batteryPowerWatts: Double = 0.0,
        batteryVoltage: Double = 0.0,
        batteryAmperage: Double = 0.0,
        adapterVoltage: Double? = nil,
        adapterCurrent: Double? = nil,
        adapterDescription: String? = nil,
        cycleCount: Int? = nil,
        designCapacity: Int? = nil,
        temperatureCelsius: Double? = nil,
        condition: String? = nil
    ) {
        self.isPluggedIn = isPluggedIn
        self.isCharging = isCharging
        self.isFullyCharged = isFullyCharged
        self.currentCapacity = currentCapacity
        self.maxCapacity = maxCapacity
        self.percentage = percentage
        self.adapterWatts = adapterWatts
        self.systemPowerInWatts = systemPowerInWatts
        self.systemLoadWatts = systemLoadWatts
        self.batteryPowerWatts = batteryPowerWatts
        self.batteryVoltage = batteryVoltage
        self.batteryAmperage = batteryAmperage
        self.adapterVoltage = adapterVoltage
        self.adapterCurrent = adapterCurrent
        self.adapterDescription = adapterDescription
        self.cycleCount = cycleCount
        self.designCapacity = designCapacity
        self.temperatureCelsius = temperatureCelsius
        self.condition = condition
    }

    /// Định dạng chuỗi hiển thị trên Menu Bar tuỳ theo chế độ
    public func menuBarText(mode: MenuBarDisplayMode, showPercentage: Bool) -> String {
        var powerText = ""

        if isPluggedIn {
            switch mode {
            case .livePower:
                if let live = systemPowerInWatts {
                    powerText = String(format: "%.1fW", live)
                } else if let adapter = adapterWatts {
                    powerText = String(format: "%.0fW", adapter)
                } else if abs(batteryPowerWatts) > 0.1 {
                    powerText = String(format: "%.1fW", abs(batteryPowerWatts))
                } else {
                    powerText = "0W"
                }

            case .adapterPower:
                if let adapter = adapterWatts {
                    powerText = String(format: "%.0fW", adapter)
                } else if let live = systemPowerInWatts {
                    powerText = String(format: "%.1fW", live)
                } else {
                    powerText = "AC"
                }

            case .combined:
                let live = systemPowerInWatts ?? abs(batteryPowerWatts)
                if let adapter = adapterWatts {
                    powerText = String(format: "%.1fW/%.0fW", live, adapter)
                } else {
                    powerText = String(format: "%.1fW", live)
                }

            case .batteryFlow:
                if isCharging {
                    powerText = String(format: "+%.1fW", abs(batteryPowerWatts))
                } else {
                    powerText = String(format: "%.1fW", abs(batteryPowerWatts))
                }
            }
        } else {
            // Đang dùng pin không cắm sạc: hiển thị công suất xả
            let discharge = abs(batteryPowerWatts)
            if discharge > 0.05 {
                powerText = String(format: "-%.1fW", discharge)
            } else {
                powerText = "Pin"
            }
        }

        if showPercentage {
            return "\(powerText) (\(percentage)%)"
        } else {
            return powerText
        }
    }

    /// Icon tương ứng cho trạng thái
    public var statusIconName: String {
        if isPluggedIn {
            if isCharging {
                return "bolt.fill"
            } else if isFullyCharged {
                return "bolt.badge.checkmark.fill"
            } else {
                return "powerplug.fill"
            }
        } else {
            // Icon pin theo mức %
            if percentage >= 90 { return "battery.100" }
            if percentage >= 75 { return "battery.75" }
            if percentage >= 50 { return "battery.50" }
            if percentage >= 25 { return "battery.25" }
            return "battery.0"
        }
    }

    /// Tình trạng pin tính theo phần trăm sức khoẻ
    public var healthPercentage: Double? {
        guard let design = designCapacity, design > 0,
              let max = maxCapacity as Int?, max > 0 else { return nil }
        // Một số máy maxCapacity là %, một số là mAh
        if max <= 100 {
            return Double(max)
        }
        return min(100.0, (Double(max) / Double(design)) * 100.0)
    }
}
