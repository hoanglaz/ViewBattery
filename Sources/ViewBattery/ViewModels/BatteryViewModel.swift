import Foundation
import SwiftUI
import AppKit

@MainActor
public class BatteryViewModel: ObservableObject {
    @Published public var batteryInfo: BatteryInfo = BatteryInfo()
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

    private var timer: Timer?
    private let service = BatteryService.shared

    // Callback khi title thay đổi để AppDelegate cập nhật NSStatusItem
    public var onTitleChanged: ((String, String) -> Void)?

    public init() {
        let savedMode = UserDefaults.standard.string(forKey: "MenuBarDisplayMode") ?? MenuBarDisplayMode.livePower.rawValue
        self.displayMode = MenuBarDisplayMode(rawValue: savedMode) ?? .livePower
        self.showPercentage = UserDefaults.standard.bool(forKey: "ShowPercentage")
        self.showIcon = UserDefaults.standard.object(forKey: "ShowIcon") == nil ? true : UserDefaults.standard.bool(forKey: "ShowIcon")

        refresh()
        startMonitoring()
        registerSystemNotifications()
    }

    public func startMonitoring(interval: TimeInterval = 2.0) {
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
        let newInfo = service.fetchBatteryInfo()
        self.batteryInfo = newInfo
        self.lastUpdated = Date()
        updateMenuBarTitle()
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
