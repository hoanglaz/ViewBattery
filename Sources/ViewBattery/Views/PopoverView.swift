import SwiftUI

public struct PopoverView: View {
    @ObservedObject public var viewModel: BatteryViewModel

    public init(viewModel: BatteryViewModel) {
        self.viewModel = viewModel
    }

    private var info: BatteryInfo {
        viewModel.batteryInfo
    }

    private var lang: AppLanguage {
        viewModel.language
    }

    private func t(_ key: String) -> String {
        LocalizedString.tr(key, lang: lang)
    }

    public var body: some View {
        VStack(spacing: 12) {
            // MARK: - Header
            headerSection

            Divider()
                .opacity(0.6)

            // MARK: - Hero Power Banner
            heroPowerSection

            // MARK: - Metric Cards Grid
            metricsGridSection

            Divider()
                .opacity(0.6)

            // MARK: - Menu Bar Customization & Language
            settingsSection

            Divider()
                .opacity(0.6)

            // MARK: - Footer & Quit Action
            footerSection
        }
        .padding(14)
        .frame(width: 330)
        .background(
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()
        )
    }

    // MARK: - 1. Header Section
    private var headerSection: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "bolt.batteryblock.fill")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 14, weight: .bold))
                Text("ViewBattery")
                    .font(.system(size: 13, weight: .bold))
            }

            Spacer()

            // Status Badge
            statusBadge

            // Refresh Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.refresh()
                }
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .help(t("menu.refresh"))
        }
    }

    private var statusBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(badgeColor)
                .frame(width: 6, height: 6)
            Text(badgeText)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(badgeColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(badgeColor.opacity(0.12))
        .clipShape(Capsule())
    }

    private var badgeColor: Color {
        if info.isPluggedIn {
            return info.isCharging ? .green : .blue
        } else {
            return .orange
        }
    }

    private var badgeText: String {
        if info.isPluggedIn {
            return info.isCharging ? t("status.charging") : t("status.ac_power")
        } else {
            return t("status.on_battery")
        }
    }

    // MARK: - 2. Hero Power Section
    private var heroPowerSection: some View {
        VStack(spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(heroLabel)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(heroWattValue)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .monospacedDigit()
                        Text("W")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Battery % & Progress
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: info.statusIconName)
                            .font(.system(size: 13))
                            .foregroundColor(badgeColor)
                        Text("\(info.percentage)%")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .monospacedDigit()
                    }

                    if let health = info.healthPercentage {
                        Text(String(format: t("hero.health"), Int(health)))
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Battery visual bar
            BatteryProgressView(
                percentage: info.percentage,
                isCharging: info.isCharging,
                isPluggedIn: info.isPluggedIn
            )
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.4))
        )
    }

    private var heroLabel: String {
        if info.isPluggedIn {
            if info.systemPowerInWatts != nil {
                return t("hero.power_in")
            } else if info.adapterWatts != nil {
                return t("hero.adapter_power")
            } else {
                return t("hero.battery_charge")
            }
        } else {
            return t("hero.battery_discharge")
        }
    }

    private var heroWattValue: String {
        if info.isPluggedIn {
            if let live = info.systemPowerInWatts {
                return String(format: "%.1f", live)
            } else if let adapter = info.adapterWatts {
                return String(format: "%.0f", adapter)
            } else {
                return String(format: "%.1f", abs(info.batteryPowerWatts))
            }
        } else {
            return String(format: "%.1f", abs(info.batteryPowerWatts))
        }
    }

    // MARK: - 3. Metrics Grid Section (2x2)
    private var metricsGridSection: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
            // Card 1: Củ sạc (Adapter)
            MetricCard(
                icon: "powerplug.fill",
                iconColor: .blue,
                title: t("card.adapter_title"),
                value: adapterValueString,
                subtitle: adapterSubtitleString
            )

            // Card 2: Dòng nạp/xả Pin
            MetricCard(
                icon: "bolt.ring.closed",
                iconColor: info.isCharging ? .green : .orange,
                title: info.isCharging ? t("card.battery_flow_in") : t("card.battery_flow_out"),
                value: batteryFlowString,
                subtitle: String(format: "%.2f V • %.0f mA", info.batteryVoltage, info.batteryAmperage * 1000)
            )

            // Card 3: Nhiệt độ
            MetricCard(
                icon: "thermometer.medium",
                iconColor: temperatureColor,
                title: t("card.temp_title"),
                value: temperatureString,
                subtitle: info.condition ?? t("card.condition_good")
            )

            // Card 4: Chu kỳ sạc (Cycles)
            MetricCard(
                icon: "arrow.triangle.2.circlepath",
                iconColor: .purple,
                title: t("card.cycle_title"),
                value: cycleCountString,
                subtitle: designCapacitySubtitle
            )
        }
    }

    private var adapterValueString: String {
        if let watts = info.adapterWatts {
            return "\(Int(watts)) W"
        } else if info.isPluggedIn {
            return t("card.adapter_connected")
        } else {
            return t("card.adapter_disconnected")
        }
    }

    private var adapterSubtitleString: String {
        if let v = info.adapterVoltage, let a = info.adapterCurrent {
            return String(format: "%.1f V • %.2f A", v, a)
        } else if let desc = info.adapterDescription {
            return desc
        } else {
            return t("card.on_battery_desc")
        }
    }

    private var batteryFlowString: String {
        let watts = abs(info.batteryPowerWatts)
        if info.isPluggedIn {
            if info.isCharging {
                return String(format: "+%.1f W", watts)
            } else {
                return t("card.battery_full_idle")
            }
        } else {
            return String(format: "-%.1f W", watts)
        }
    }

    private var temperatureString: String {
        if let temp = info.temperatureCelsius {
            return String(format: "%.1f °C", temp)
        } else {
            return "-- °C"
        }
    }

    private var temperatureColor: Color {
        guard let temp = info.temperatureCelsius else { return .secondary }
        if temp > 40 { return .red }
        if temp > 33 { return .orange }
        return .green
    }

    private var cycleCountString: String {
        if let cycles = info.cycleCount {
            return String(format: t("card.cycle_count"), cycles)
        } else {
            return "--"
        }
    }

    private var designCapacitySubtitle: String {
        if let design = info.designCapacity {
            return String(format: t("card.design_capacity"), design)
        } else {
            return t("card.original_capacity")
        }
    }

    // MARK: - 4. Settings Section (Language & Menu Bar)
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Language selector toggle
            HStack {
                Text(t("settings.language"))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)

                Spacer()

                Picker("Language", selection: $viewModel.language) {
                    Text("English").tag(AppLanguage.en)
                    Text("Tiếng Việt").tag(AppLanguage.vi)
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 150)
            }

            // Menu Bar Display Mode
            Text(t("settings.menubar_title"))
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)

            Picker("Chế độ hiển thị", selection: $viewModel.displayMode) {
                Text(t("settings.mode_live")).tag(MenuBarDisplayMode.livePower)
                Text(t("settings.mode_adapter")).tag(MenuBarDisplayMode.adapterPower)
                Text(t("settings.mode_combined")).tag(MenuBarDisplayMode.combined)
                Text(t("settings.mode_flow")).tag(MenuBarDisplayMode.batteryFlow)
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            HStack {
                Toggle(t("settings.show_percentage"), isOn: $viewModel.showPercentage)
                    .font(.system(size: 11))
                    .toggleStyle(.checkbox)

                Spacer()

                Toggle(t("settings.show_icon"), isOn: $viewModel.showIcon)
                    .font(.system(size: 11))
                    .toggleStyle(.checkbox)
            }
        }
    }

    // MARK: - 5. Footer & Quit
    private var footerSection: some View {
        HStack {
            Text(timeString(from: viewModel.lastUpdated))
                .font(.system(size: 10))
                .foregroundColor(.secondary)

            Spacer()

            Button(action: {
                viewModel.quitApp()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "power")
                        .font(.system(size: 10, weight: .bold))
                    Text(t("footer.quit"))
                        .font(.system(size: 11, weight: .medium))
                }
                .foregroundColor(.red.opacity(0.85))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
            }
            .buttonStyle(.plain)
            .keyboardShortcut("q", modifiers: .command)
            .help(t("footer.quit_help"))
        }
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return String(format: t("footer.updated_at"), formatter.string(from: date))
    }
}
