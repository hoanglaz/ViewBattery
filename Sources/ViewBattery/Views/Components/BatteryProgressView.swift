import SwiftUI

public struct BatteryProgressView: View {
    public let percentage: Int
    public let isCharging: Bool
    public let isPluggedIn: Bool

    public init(percentage: Int, isCharging: Bool, isPluggedIn: Bool) {
        self.percentage = percentage
        self.isCharging = isCharging
        self.isPluggedIn = isPluggedIn
    }

    private var statusColor: Color {
        if isCharging {
            return .green
        } else if percentage <= 20 {
            return .red
        } else if percentage <= 40 {
            return .orange
        } else {
            return .accentColor
        }
    }

    public var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Thanh nền
                    Capsule()
                        .fill(Color.primary.opacity(0.08))
                        .frame(height: 8)

                    // Thanh tiến độ phần trăm
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [statusColor, statusColor.opacity(0.85)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(8, geo.size.width * CGFloat(min(100, max(0, percentage))) / 100.0), height: 8)
                        .animation(.smooth(duration: 0.3), value: percentage)
                }
            }
            .frame(height: 8)
        }
    }
}
