# ViewBattery ⚡️

Ứng dụng macOS Menu Bar native viết hoàn toàn bằng **Swift** & **SwiftUI**, giúp theo dõi công suất sạc và nguồn điện theo thời gian thực (realtime) trực tiếp trên thanh menu macOS.

---

## ✨ Tính năng nổi bật

1. **Hiển thị Realtime trên Menu Bar**:
   - Hiển thị công suất sạc nhận thực tế (`⚡️ 10.6W`), công suất định danh của củ sạc (`⚡️ 67W`), hoặc kết hợp cả hai (`10.6W/67W`).
   - Khi rút sạc (chạy pin): tự động chuyển sang hiển thị công suất xả (`-12.4W`) hoặc phần trăm pin.
   - Sử dụng font Monospaced Digit để tránh hiện tượng rung/giật chữ số trên Menu Bar khi dữ liệu cập nhật.

2. **Popover SwiftUI Hiện Đại & Tinh Tế**:
   - **Hero Metric**: Chỉ số Watt to rõ, trực quan, cập nhật mỗi 2 giây.
   - **Thanh tiến độ pin**: Animated Battery Bar kèm % pin và sức khoẻ pin.
   - **Card Củ sạc (Adapter)**: Công suất củ sạc (Watts), điện áp (V), dòng điện giới hạn (A), chuẩn kết nối (USB-C PD / MagSafe).
   - **Card Dòng pin (Battery Flow)**: Tốc độ nạp thực tế vào cell pin (+/- W), điện áp pin và dòng mA.
   - **Card Nhiệt độ & Sức khoẻ**: Nhiệt độ pin (°C) đổi màu theo nhiệt độ, tình trạng pin.
   - **Card Chu kỳ sạc (Cycle Count)**: Số lần sạc xả và dung lượng gốc của pin (mAh).

3. **Tùy biến nhanh chóng**:
   - Cho phép đổi giữa 4 chế độ hiển thị Menu Bar ngay trong Popover: *Thực tế*, *Củ sạc*, *Cả hai*, *Dòng pin*.
   - Bật/tắt hiển thị kèm phần trăm pin `%` và icon tia sét `⚡️`.

4. **Trải nghiệm Native macOS**:
   - Không chiếm diện tích dưới thanh Dock (`LSUIElement = true`).
   - Tự động đóng popover khi click ra ngoài (`transient behavior`).
   - Chuột phải vào biểu tượng trên Menu Bar để mở menu ngữ cảnh nhanh: *Làm mới* và *Thoát ViewBattery*.
   - Nút **Thoát ViewBattery** tích hợp sẵn phím tắt `⌘Q`.
   - Tiêu thụ tài nguyên siêu nhẹ (< 0.05% CPU, không hao pin).

---

## 🚀 Cách cài đặt & Sử dụng

### Cách 1: Tải và cài đặt trực tiếp qua file .dmg (Khuyên dùng)
Bạn có thể tải hoặc mở trực tiếp tệp **[ViewBattery.dmg](file:///Users/hoangla/Documents/Project/ViewBattery/ViewBattery.dmg)**:
1. Mở tệp `ViewBattery.dmg`.
2. Kéo thả biểu tượng **ViewBattery** vào thư mục **Applications**.
3. Mở ứng dụng từ Launchpad hoặc Spotlight. Biểu tượng công suất sẽ xuất hiện ngay trên Menu Bar!

### Cách 2: Chạy trực tiếp từ mã nguồn (Development)
```bash
swift run
```

### Cách 3: Tự đóng gói lại file .app hoặc .dmg
```bash
# Đóng gói ViewBattery.app
./scripts/build_app.sh

# Đóng gói bộ cài đặt ViewBattery.dmg
./scripts/create_dmg.sh
```

---

## 🛠 Cấu trúc mã nguồn

```
ViewBattery/
├── Package.swift                    # Khai báo Swift Package (macOS 13+)
├── scripts/
│   └── build_app.sh                 # Script biên dịch Release & đóng gói .app
└── Sources/ViewBattery/
    ├── ViewBatteryApp.swift         # Entry point chính (@main, @MainActor)
    ├── AppDelegate.swift            # Quản lý NSStatusItem, NSPopover, Right-click context menu
    ├── Models/
    │   └── BatteryInfo.swift        # Model dữ liệu nguồn điện, công suất và pin
    ├── Services/
    │   └── BatteryService.swift     # Đọc IOKit AppleSmartBattery & IOPMPowerSource
    ├── ViewModels/
    │   └── BatteryViewModel.swift   # Quản lý state, timer chu kỳ đọc và cấu hình hiển thị
    └── Views/
        ├── Components/
        │   ├── MetricCard.swift     # Thẻ hiển thị chỉ số native macOS
        │   └── BatteryProgressView.swift # Thanh đo pin animated
        └── PopoverView.swift        # Giao diện Popover SwiftUI chính
```