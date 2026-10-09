import Foundation
import SwiftUI
import AppKit

@MainActor
public class BatteryViewModel: ObservableObject {
    @Published public var batteryInfo: BatteryInfo = BatteryInfo()

    @Published public var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "AppLanguage")
            updateMenuBarTitle()
        }
    }

    @Published public var displayMode: MenuBarDisplayMode {
        didSet {
            UserDefaults.standard.set(displayMode.rawValue, forKey: "MenuBarDisplayMode")
            updateMenuBarTitle()
        }
    }

    @Published public var showPercentage: Bool {
        didSet {
            UserDefaults.standard.set(showPercentage, forKey: "ShowPercentage")
            updateMenuBarTitle()
        }
    }

    @Published public var showIcon: Bool {
        didSet {
            UserDefaults.standard.set(showIcon, forKey: "ShowIcon")
            updateMenuBarTitle()
        }
    }

    @Published public var menuBarTitle: String = "⚡️ --W"
    @Published public var lastUpdated: Date = Date()
    @Published public var isPopoverVisible: Bool = false

    private var timer: Timer?
    private let service = BatteryService.shared

    // Callback khi title thay đổi để AppDelegate cập nhật NSStatusItem
    public var onTitleChanged: ((String, String) -> Void)?

    public init() {
        // Mặc định ngôn ngữ là English theo yêu cầu người dùng
        let savedLang = UserDefaults.standard.string(forKey: "AppLanguage") ?? AppLanguage.en.rawValue
        self.language = AppLanguage(rawValue: savedLang) ?? .en

        let savedMode = UserDefaults.standard.string(forKey: "MenuBarDisplayMode") ?? MenuBarDisplayMode.livePower.rawValue
        self.displayMode = MenuBarDisplayMode(rawValue: savedMode) ?? .livePower
        self.showPercentage = UserDefaults.standard.bool(forKey: "ShowPercentage")
        self.showIcon = UserDefaults.standard.object(forKey: "ShowIcon") == nil ? true : UserDefaults.standard.bool(forKey: "ShowIcon")

        refresh()
        startMonitoring(interval: 3.0)
        registerSystemNotifications()
    }

    public func localized(_ key: String, _ args: CVarArg...) -> String {
        let dict = LocalizedString.tr(key, lang: language, args)
        return dict
    }

    public func setPopoverVisible(_ visible: Bool) {
        self.isPopoverVisible = visible
        // Khi popover mở: cập nhật nhanh hơn (1.5s), khi đóng: giãn cách 3.0s để tiết kiệm RAM & CPU
        startMonitoring(interval: visible ? 1.5 : 3.0)
        if visible {
            refresh()
        }
    }

    public func startMonitoring(interval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
    }

    public func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    public func refresh() {
        autoreleasepool {
            let newInfo = service.fetchBatteryInfo()
            self.batteryInfo = newInfo
            self.lastUpdated = Date()
            updateMenuBarTitle()
        }
    }

    private func updateMenuBarTitle() {
        let text = batteryInfo.menuBarText(mode: displayMode, showPercentage: showPercentage)
        let iconName = batteryInfo.statusIconName
        let fullTitle = showIcon ? "⚡️ \(text)" : text
        self.menuBarTitle = fullTitle

        onTitleChanged?(text, iconName)
    }

    private func registerSystemNotifications() {
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
    }

    public func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
