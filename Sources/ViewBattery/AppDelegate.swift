import Cocoa
import SwiftUI

@MainActor
public class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover?
    private var viewModel: BatteryViewModel!

    public func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Ẩn icon trên Dock, chạy như một menu bar accessory app thuần tuý
        NSApp.setActivationPolicy(.accessory)

        // 2. Khởi tạo ViewModel (nhẹ, quản lý timer và IOKit)
        viewModel = BatteryViewModel()

        // 3. Khởi tạo NSStatusItem trên thanh Menu Bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.target = self
            button.action = #selector(handleStatusItemClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        // Đăng ký callback khi thông số thay đổi để cập nhật button
        viewModel.onTitleChanged = { [weak self] text, iconName in
            self?.updateStatusButton(text: text, iconName: iconName)
        }

        // Cập nhật lần đầu
        let text = viewModel.batteryInfo.menuBarText(mode: viewModel.displayMode, showPercentage: viewModel.showPercentage)
        updateStatusButton(text: text, iconName: viewModel.batteryInfo.statusIconName)

        // LƯU Ý TỐI ƯU RAM: Popover KHÔNG khởi tạo ở đây!
        // Sẽ được lazy-load khi người dùng click vào Menu Bar lần đầu tiên.
    }

    private func updateStatusButton(text: String, iconName: String) {
        guard let button = statusItem.button else { return }

        // Dùng monospaced digit font để menubar không bị giật kích thước khi số thay đổi
        let font = NSFont.monospacedDigitSystemFont(ofSize: 12.0, weight: .medium)
        button.font = font

        if viewModel.showIcon {
            let config = NSImage.SymbolConfiguration(pointSize: 11, weight: .medium)
            button.image = NSImage(systemSymbolName: iconName, accessibilityDescription: "Charging status")?.withSymbolConfiguration(config)
            button.imagePosition = .imageLeading
            button.title = " \(text)"
        } else {
            button.image = nil
            button.title = text
        }
    }

    @objc private func handleStatusItemClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            // Click chuột phải: Hiện menu ngữ cảnh nhanh
            showContextMenu()
        } else {
            // Click chuột trái: Mở / Đóng Popover SwiftUI
            togglePopover()
        }
    }

    private func getOrCreatePopover() -> NSPopover {
        if let existing = popover {
            return existing
        }

        let newPopover = NSPopover()
        newPopover.contentSize = NSSize(width: 330, height: 490)
        newPopover.behavior = .transient
        newPopover.delegate = self
        newPopover.contentViewController = NSHostingController(rootView: PopoverView(viewModel: viewModel))
        self.popover = newPopover
        return newPopover
    }

    private func togglePopover() {
        guard let button = statusItem.button else { return }
        let currentPopover = getOrCreatePopover()

        if currentPopover.isShown {
            currentPopover.performClose(nil)
        } else {
            // Làm mới dữ liệu trước khi hiện
            viewModel.refresh()
            currentPopover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            currentPopover.contentViewController?.view.window?.makeKey()
        }
    }

    // MARK: - NSPopoverDelegate
    public func popoverWillShow(_ notification: Notification) {
        viewModel.setPopoverVisible(true)
    }

    public func popoverDidClose(_ notification: Notification) {
        viewModel.setPopoverVisible(false)
    }

    private func showContextMenu() {
        let menu = NSMenu()
        let lang = viewModel.language

        let refreshTitle = LocalizedString.tr("menu.refresh", lang: lang)
        let refreshItem = NSMenuItem(title: refreshTitle, action: #selector(refreshClicked), keyEquivalent: "r")
        refreshItem.target = self
        menu.addItem(refreshItem)

        menu.addItem(NSMenuItem.separator())

        let quitTitle = LocalizedString.tr("menu.quit", lang: lang)
        let quitItem = NSMenuItem(title: quitTitle, action: #selector(quitClicked), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil // Gỡ bỏ sau khi hiển thị để click chuột trái vẫn mở popover
    }

    @objc private func refreshClicked() {
        viewModel.refresh()
    }

    @objc private func quitClicked() {
        NSApp.terminate(nil)
    }
}
