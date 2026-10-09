import Foundation

public enum AppLanguage: String, CaseIterable, Identifiable {
    case en = "en"
    case vi = "vi"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .en: return "English"
        case .vi: return "Tiếng Việt"
        }
    }
}

public struct LocalizedString {
    public static func tr(_ key: String, lang: AppLanguage, _ args: CVarArg...) -> String {
        let dict = strings[lang] ?? strings[.en]!
        let format = dict[key] ?? strings[.en]?[key] ?? key
        if args.isEmpty {
            return format
        }
        return String(format: format, arguments: args)
    }

    private static let strings: [AppLanguage: [String: String]] = [
        .en: [
            // Status Badges
            "status.charging": "Charging",
            "status.ac_power": "AC Power",
            "status.on_battery": "On Battery",

            // Hero Labels
            "hero.power_in": "Current power input",
            "hero.adapter_power": "Connected charger rating",
            "hero.battery_charge": "Power entering battery",
            "hero.battery_discharge": "Power discharging",
            "hero.health": "Health: %d%%",

            // Metric Cards
            "card.adapter_title": "Charger (Adapter)",
            "card.adapter_connected": "Connected",
            "card.adapter_disconnected": "Disconnected",
            "card.on_battery_desc": "Running on battery",

            "card.battery_flow_in": "Charging battery",
            "card.battery_flow_out": "Battery flow",
            "card.battery_full_idle": "0.0 W (Idle/Full)",

            "card.temp_title": "Battery Temp",
            "card.condition_good": "Normal condition",

            "card.cycle_title": "Cycle Count",
            "card.cycle_count": "%d cycles",
            "card.design_capacity": "%d mAh design",
            "card.original_capacity": "Original capacity",

            // Menu Bar Display Settings
            "settings.menubar_title": "Menu Bar Display",
            "settings.mode_live": "Live",
            "settings.mode_adapter": "Charger",
            "settings.mode_combined": "Both",
            "settings.mode_flow": "Battery",
            "settings.show_percentage": "Show battery percentage",
            "settings.show_icon": "Show icon ⚡️",

            // Language
            "settings.language": "Language",

            // Footer & Actions
            "footer.updated_at": "Updated: %@",
            "footer.quit": "Quit ViewBattery",
            "footer.quit_help": "Quit application (⌘Q)",
            "menu.refresh": "Refresh data",
            "menu.quit": "Quit ViewBattery"
        ],
        .vi: [
            // Status Badges
            "status.charging": "Đang sạc",
            "status.ac_power": "Nguồn AC",
            "status.on_battery": "Đang dùng pin",

            // Hero Labels
            "hero.power_in": "Công suất máy đang nhận",
            "hero.adapter_power": "Công suất củ sạc kết nối",
            "hero.battery_charge": "Công suất nạp vào pin",
            "hero.battery_discharge": "Công suất pin đang xả",
            "hero.health": "Sức khoẻ: %d%%",

            // Metric Cards
            "card.adapter_title": "Củ sạc (Adapter)",
            "card.adapter_connected": "Đã kết nối",
            "card.adapter_disconnected": "Không cắm",
            "card.on_battery_desc": "Chạy bằng pin",

            "card.battery_flow_in": "Nạp vào pin",
            "card.battery_flow_out": "Dòng pin",
            "card.battery_full_idle": "0.0 W (Đầy/Ngưng)",

            "card.temp_title": "Nhiệt độ pin",
            "card.condition_good": "Tình trạng tốt",

            "card.cycle_title": "Chu kỳ sạc",
            "card.cycle_count": "%d chu kỳ",
            "card.design_capacity": "%d mAh thiết kế",
            "card.original_capacity": "Dung lượng gốc",

            // Menu Bar Display Settings
            "settings.menubar_title": "Hiển thị trên Menu Bar",
            "settings.mode_live": "Thực tế",
            "settings.mode_adapter": "Củ sạc",
            "settings.mode_combined": "Cả hai",
            "settings.mode_flow": "Dòng pin",
            "settings.show_percentage": "Hiện kèm phần trăm pin",
            "settings.show_icon": "Hiện icon ⚡️",

            // Language
            "settings.language": "Ngôn ngữ",

            // Footer & Actions
            "footer.updated_at": "Cập nhật: %@",
            "footer.quit": "Thoát ViewBattery",
            "footer.quit_help": "Thoát ứng dụng (⌘Q)",
            "menu.refresh": "Làm mới thông số",
            "menu.quit": "Thoát ViewBattery"
        ]
    ]
}
