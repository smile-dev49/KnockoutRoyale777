import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: GameStore
    @Binding var path: NavigationPath
    var onSettings: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                TopBarView(onSettings: onSettings)

                heroBlock

                GoldButton(title: "★  PLAY  ★") {
                    path.append(HomeRoute.arenas)
                }
                .padding(.horizontal, 28)

                HStack(spacing: 12) {
                    dailyBonusCard
                    featuredCard
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 20)
            }
            .padding(.bottom, 24)
        }
        .background(Color.clear)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var heroBlock: some View {
        ZStack {
            Circle()
                .fill(AppTheme.purpleGlow.opacity(0.35))
                .frame(width: 260, height: 260)
                .blur(radius: 40)

            VStack(spacing: 10) {
                HStack(spacing: -8) {
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 54))
                        .foregroundStyle(AppTheme.ruby)
                        .rotationEffect(.degrees(-25))
                        .shadow(color: AppTheme.ruby.opacity(0.6), radius: 12)
                    Image(systemName: "sparkle")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.goldLight)
                        .offset(y: -10)
                    Image(systemName: "hand.raised.fill")
                        .font(.system(size: 54))
                        .foregroundStyle(Color.black)
                        .rotationEffect(.degrees(25))
                        .shadow(color: AppTheme.gold.opacity(0.5), radius: 12)
                }

                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { _ in
                        Text("7")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(AppTheme.ruby)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(AppTheme.gold.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(AppTheme.gold, lineWidth: 1.5)
                                    )
                            )
                    }
                }

                Text("KNOCKOUT")
                    .font(.system(size: 36, weight: .black, design: .serif))
                    .foregroundStyle(AppTheme.goldGradient)
                    .shadow(color: AppTheme.gold.opacity(0.5), radius: 8)

                Text("ROYALE  777")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundStyle(AppTheme.goldLight)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(AppTheme.ruby.opacity(0.85)))
                    .overlay(Capsule().stroke(AppTheme.gold, lineWidth: 1))
            }
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity)
    }

    private var dailyBonusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(AppTheme.gold)
                Text(store.resetTimerText)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Image(systemName: "shippingbox.fill")
                .font(.system(size: 36))
                .foregroundStyle(AppTheme.goldGradient)
                .frame(maxWidth: .infinity)

            Text("Come back every day for bigger rewards!")
                .font(.system(size: 11))
                .foregroundStyle(AppTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            GoldButton(
                title: store.dailyBonusAvailable ? "COLLECT" : "COLLECTED",
                style: store.dailyBonusAvailable ? .gold : .muted,
                compact: true,
                badge: store.dailyBonusAvailable ? 1 : nil
            ) {
                _ = store.claimDailyBonusChest()
            }
            .disabled(!store.dailyBonusAvailable)
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 190, alignment: .top)
        .casinoPanel(cornerRadius: 14)
    }

    private var featuredCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("FEATURED MODE")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(AppTheme.gold)

            Text("KNOCKOUT\nTOURNAMENT")
                .font(.system(size: 14, weight: .black, design: .serif))
                .foregroundStyle(AppTheme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Image(systemName: "trophy.fill")
                .font(.system(size: 34))
                .foregroundStyle(AppTheme.goldGradient)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)

            GoldButton(title: "PLAY NOW", style: .gold, compact: true) {
                path.append(ArenaType.tournament)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, minHeight: 190, alignment: .top)
        .casinoPanel(cornerRadius: 14)
    }
}
