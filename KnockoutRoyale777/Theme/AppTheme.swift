import SwiftUI

enum AppTheme {
    static let background = Color(red: 0.04, green: 0.03, blue: 0.06)
    static let backgroundSecondary = Color(red: 0.09, green: 0.07, blue: 0.12)
    static let panel = Color(red: 0.12, green: 0.09, blue: 0.14)
    static let panelStroke = Color(red: 0.72, green: 0.55, blue: 0.18)

    static let gold = Color(red: 0.95, green: 0.78, blue: 0.28)
    static let goldLight = Color(red: 1.0, green: 0.92, blue: 0.55)
    static let goldDark = Color(red: 0.62, green: 0.42, blue: 0.08)

    static let ruby = Color(red: 0.72, green: 0.08, blue: 0.14)
    static let rubyDeep = Color(red: 0.42, green: 0.04, blue: 0.08)
    static let emerald = Color(red: 0.18, green: 0.72, blue: 0.38)
    static let purpleGlow = Color(red: 0.45, green: 0.18, blue: 0.72)

    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.78)
    static let textMuted = Color(white: 0.55)

    static var goldGradient: LinearGradient {
        LinearGradient(
            colors: [goldLight, gold, goldDark],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var rubyGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.85, green: 0.18, blue: 0.22), ruby, rubyDeep],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.12, green: 0.05, blue: 0.16),
                background,
                Color(red: 0.06, green: 0.02, blue: 0.04)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

struct GoldStroke: ViewModifier {
    var cornerRadius: CGFloat = 16
    var lineWidth: CGFloat = 1.5

    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(AppTheme.goldGradient, lineWidth: lineWidth)
        )
    }
}

extension View {
    func goldStroke(cornerRadius: CGFloat = 16, lineWidth: CGFloat = 1.5) -> some View {
        modifier(GoldStroke(cornerRadius: cornerRadius, lineWidth: lineWidth))
    }

    func casinoPanel(cornerRadius: CGFloat = 16) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(AppTheme.panel.opacity(0.92))
        )
        .goldStroke(cornerRadius: cornerRadius)
    }
}

enum CoinFormat {
    static func string(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    static func compact(_ value: Int) -> String {
        switch value {
        case 1_000_000...:
            let m = Double(value) / 1_000_000
            return m.truncatingRemainder(dividingBy: 1) == 0
                ? "\(Int(m))M"
                : String(format: "%.1fM", m)
        case 1_000...:
            let k = Double(value) / 1_000
            return k.truncatingRemainder(dividingBy: 1) == 0
                ? "\(Int(k))K"
                : String(format: "%.0fK", k)
        default:
            return "\(value)"
        }
    }
}
