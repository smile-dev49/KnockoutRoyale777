import SwiftUI

struct TopBarView: View {
    @EnvironmentObject private var store: GameStore
    var onSettings: () -> Void = {}

    var body: some View {
        HStack(spacing: 10) {
            LogoMark()
                .frame(width: 86, height: 44)

            Spacer(minLength: 4)

            HStack(spacing: 8) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .foregroundStyle(AppTheme.goldGradient)
                    .font(.system(size: 18, weight: .bold))
                Text(CoinFormat.string(store.coins))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.goldLight)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(Color.black.opacity(0.55)))
            .overlay(Capsule().stroke(AppTheme.gold.opacity(0.7), lineWidth: 1.2))

            Spacer(minLength: 4)

            Button(action: onSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppTheme.gold)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.black.opacity(0.55)))
                    .overlay(Circle().stroke(AppTheme.gold.opacity(0.7), lineWidth: 1.2))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }
}

struct LogoMark: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("KNOCKOUT")
                .font(.system(size: 11, weight: .black, design: .serif))
                .foregroundStyle(AppTheme.goldGradient)
            Text("ROYALE")
                .font(.system(size: 9, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.goldLight)
            HStack(spacing: 2) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 7))
                Text("777")
                    .font(.system(size: 10, weight: .heavy, design: .rounded))
            }
            .foregroundStyle(AppTheme.ruby)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.black.opacity(0.45))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(AppTheme.gold.opacity(0.5), lineWidth: 1)
        )
        .accessibilityLabel("Knockout Royale 777")
    }
}

struct GoldButton: View {
    let title: String
    var style: Style = .ruby
    var compact: Bool = false
    var badge: Int? = nil
    let action: () -> Void

    enum Style { case ruby, gold, muted }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: compact ? 13 : 16, weight: .black, design: .rounded))
                .foregroundStyle(foreground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, compact ? 10 : 14)
                .background(background)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AppTheme.gold.opacity(0.85), lineWidth: 1.5))
                .shadow(color: glow, radius: 8, y: 2)
                .overlay(alignment: .topTrailing) {
                    if let badge, badge > 0 {
                        Text("\(badge)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(5)
                            .background(Circle().fill(AppTheme.ruby))
                            .offset(x: 6, y: -6)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private var foreground: Color {
        switch style {
        case .ruby: return AppTheme.goldLight
        case .gold: return Color.black.opacity(0.85)
        case .muted: return AppTheme.textSecondary
        }
    }

    private var background: AnyShapeStyle {
        switch style {
        case .ruby: return AnyShapeStyle(AppTheme.rubyGradient)
        case .gold: return AnyShapeStyle(AppTheme.goldGradient)
        case .muted: return AnyShapeStyle(Color.white.opacity(0.08))
        }
    }

    private var glow: Color {
        style == .muted ? .clear : AppTheme.ruby.opacity(0.35)
    }
}

struct SectionTitle: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkle")
                .foregroundStyle(AppTheme.gold)
            Text(text)
                .font(.system(size: 16, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.goldGradient)
            Image(systemName: "sparkle")
                .foregroundStyle(AppTheme.gold)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DisclaimerBanner: View {
    var body: some View {
        Text("Virtual coins only · For entertainment · No real-money value or cashout")
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(AppTheme.textMuted)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
    }
}

struct SymbolTile: View {
    let symbol: SlotSymbol
    var highlighted: Bool = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.9, blue: 0.78),
                            Color(red: 0.86, green: 0.8, blue: 0.65)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Image(systemName: symbol.systemImage)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(symbol.tint)
                .shadow(color: symbol.tint.opacity(0.5), radius: highlighted ? 8 : 2)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(highlighted ? AppTheme.gold : Color.clear, lineWidth: 3)
        )
        .aspectRatio(1, contentMode: .fit)
    }
}
