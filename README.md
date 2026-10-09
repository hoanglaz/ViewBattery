# ViewBattery ⚡️

<p align="center">
  <b>A lightweight, native macOS Menu Bar application to monitor live laptop charging power and battery telemetry.</b><br>
  <i>Ứng dụng macOS Menu Bar siêu nhẹ hiển thị công suất sạc realtime và thông số pin theo thời gian thực.</i>
</p>

<p align="center">
  <a href="#english"><b>English</b></a> •
  <a href="#tiếng-việt"><b>Tiếng Việt</b></a> •
  <a href="#download--cài-đặt"><b>Download (.dmg)</b></a>
</p>

---

<a name="english"></a>
## 🇬🇧 English

### ✨ Features
1. **Real-time Menu Bar Power Display**:
   - Shows live incoming wattage (`⚡️ 10.6W`), charger rated capacity (`⚡️ 67W`), or both combined (`10.6W/67W`).
   - Automatically switches to discharge wattage (`-12.4W`) or battery percentage when unplugged.
   - Monospaced digits ensure smooth, jitter-free Menu Bar width changes.

2. **Modern SwiftUI Popover**:
   - **Hero Metric**: Large, glanceable Wattage reading with live charging status badge.
   - **Battery Bar**: Animated battery level indicator with health percentage.
   - **Charger Card**: Rated adapter wattage (e.g. 67W), voltage (V), current limit (A), and protocol (USB-C PD / MagSafe).
   - **Battery Flow Card**: Real-time power entering/leaving battery cells, voltage, and amperage.
   - **Temperature & Health Card**: Live battery temperature (°C) with color alerts and battery condition.
   - **Cycle Count Card**: Total cycle count and original design capacity (mAh).

3. **Bilingual & Customizable**:
   - Quick language toggle directly inside settings (`English` / `Tiếng Việt`). English by default.
   - 4 display modes: *Live*, *Charger*, *Both*, *Battery flow*.
   - Option to toggle `%` battery and `⚡️` icon.

4. **Engineered for High Performance & Low Memory**:
   - **Zero Dock Clutter**: Runs purely as an accessory Menu Bar agent (`LSUIElement = true`).
   - **Lazy Loading**: `NSPopover` is initialized only upon first user click.
   - **Autorelease Drainage**: Wraps IOKit polling in `autoreleasepool` to prevent memory accumulation.
   - **Adaptive Polling**: 1.5s when popover is open, 3.0s when running in background.
   - CPU usage is **< 0.05%**; memory footprint is flat and leak-free.

---

### 🚀 Download & Installation

#### Method 1: Install via DMG (Recommended)
Download **[ViewBattery.dmg](file:///Users/hoangla/Documents/Project/ViewBattery/ViewBattery.dmg)** from this repository:
1. Open `ViewBattery.dmg`.
2. Drag and drop **ViewBattery** into **Applications**.
3. Open ViewBattery from Launchpad or Spotlight. The live power icon will appear on your Menu Bar!

#### Method 2: Build & Run from Source
```bash
# Clone the repository
git clone https://github.com/hoanglaz/ViewBattery.git
cd ViewBattery

# Run immediately
swift run

# Or package your own DMG installer
./scripts/create_dmg.sh
```

#### How to Quit
- Open the Popover and click **Quit ViewBattery** (or press `⌘Q`).
- Alternatively, **Right-click** the Menu Bar icon and select **Quit ViewBattery**.

---

<a name="tiếng-việt"></a>
## 🇻🇳 Tiếng Việt

### ✨ Tính năng nổi bật
1. **Hiển thị Realtime trên Menu Bar**:
   - Hiển thị công suất sạc máy nhận thực tế (`⚡️ 10.6W`), công suất định danh của củ sạc (`⚡️ 67W`), hoặc kết hợp cả hai (`10.6W/67W`).
   - Tự động chuyển sang công suất xả (`-12.4W`) hoặc phần trăm khi rút sạc.
   - Sử dụng font số cách đều (Monospaced Digit) tránh giật chiều rộng thanh menu khi đổi số.

2. **Giao diện Popover SwiftUI Hiện Đại**:
   - **Chỉ số Hero**: Số Watt to rõ, trực quan kèm huy hiệu trạng thái nguồn điện.
   - **Thanh đo pin**: Animated Battery Bar hiển thị dung lượng và sức khoẻ pin.
   - **Thẻ Củ sạc (Adapter)**: Công suất củ sạc (W), điện áp (V), dòng điện giới hạn (A), chuẩn củ sạc (USB-C PD / MagSafe).
   - **Thẻ Dòng pin**: Tốc độ nạp thực tế vào pin (+/- W), điện áp và dòng mA.
   - **Thẻ Nhiệt độ & Sức khoẻ**: Nhiệt độ pin realtime (°C) tự đổi màu theo mức nhiệt.
   - **Thẻ Chu kỳ sạc**: Số lần sạc/xả và dung lượng thiết kế (mAh).

3. **Hỗ trợ Song ngữ & Tùy biến cao**:
   - Nút gạt chuyển đổi nhanh giữa `English` và `Tiếng Việt` ngay trong phần cài đặt (mặc định: Tiếng Anh).
   - 4 chế độ hiển thị trên Menu Bar: *Thực tế*, *Củ sạc*, *Cả hai*, *Dòng pin*.
   - Cho phép bật/tắt hiển thị kèm `% pin` và icon `⚡️`.

4. **Tối ưu RAM & Hiệu năng hệ thống**:
   - **Chạy nền chuẩn native**: Không chiếm diện tích Dock (`LSUIElement = true`).
   - **Lazy Loading**: Popover chỉ được cấp phát bộ nhớ khi người dùng click vào lần đầu tiên.
   - **Giải phóng bộ nhớ tự động**: Gom IOKit query vào `autoreleasepool` để dọn dẹp các đối tượng tạm mỗi chu kỳ.
   - **Polling thông minh**: 1.5 giây khi mở Popover, giãn ra 3.0 giây khi chạy nền.
   - CPU duy trì **< 0.05%**, RAM ổn định tuyệt đối không rò rỉ (leak-free).

---

### 🚀 Cách cài đặt & Sử dụng

#### Cách 1: Cài đặt nhanh qua file .dmg (Khuyên dùng)
Tải tệp **[ViewBattery.dmg](file:///Users/hoangla/Documents/Project/ViewBattery/ViewBattery.dmg)** có sẵn trong repository:
1. Mở file `ViewBattery.dmg`.
2. Kéo thả biểu tượng **ViewBattery** vào thư mục **Applications**.
3. Mở ứng dụng từ Launchpad hoặc Spotlight.

#### Cách 2: Chạy trực tiếp từ mã nguồn (Development)
```bash
git clone https://github.com/hoanglaz/ViewBattery.git
cd ViewBattery

# Chạy thử trực tiếp
swift run

# Tự đóng gói thành file .dmg
./scripts/create_dmg.sh
```

#### Cách thoát ứng dụng
- Mở Popover và nhấn nút đỏ **Thoát ViewBattery** (hoặc bấm `⌘Q`).
- Hoặc **Click chuột phải** vào icon trên Menu Bar ➔ chọn **Thoát ViewBattery**.

---

## 🛠 Cấu trúc dự án / Project Architecture

```
ViewBattery/
├── Package.swift                          # Swift Package Manifest (macOS 13+)
├── ViewBattery.dmg                        # DMG installer bundle
├── scripts/
│   ├── build_app.sh                       # Build Release .app bundle
│   └── create_dmg.sh                      # Create DMG installer
└── Sources/ViewBattery/
    ├── ViewBatteryApp.swift               # Main entry point (@main, @MainActor)
    ├── AppDelegate.swift                  # NSStatusItem, Lazy NSPopover & Context Menu
    ├── Models/
    │   └── BatteryInfo.swift              # Battery data model & Watt calculations
    ├── Services/
    │   ├── BatteryService.swift           # IOKit & IOPMPowerSource reader (autoreleasepool)
    │   └── Localization.swift             # Bilingual translation dictionary (EN/VI)
    ├── ViewModels/
    │   └── BatteryViewModel.swift         # Adaptive timer, state & preference management
    └── Views/
        ├── Components/
        │   ├── MetricCard.swift           # macOS system-native telemetry card
        │   └── BatteryProgressView.swift  # Animated battery percentage bar
        └── PopoverView.swift              # Main SwiftUI popover interface
```

---

## 📄 License
MIT License. Free to use, fork, and distribute.