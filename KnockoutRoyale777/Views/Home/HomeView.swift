import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: GameStore
    @Binding var path: NavigationPath
    var onSettings: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                TopBarView(onSettings: onSettings)

                // Leave room for the shared background's gloves / 777 artwork.
                Color.clear.frame(height: 168)

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
        .appScreenBackground()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var heroBlock: some View {
        VStack(spacing: 8) {
            Text("KNOCKOUT ROYALE")
                .font(.system(size: 28, weight: .black, design: .serif))
                .foregroundStyle(AppTheme.goldGradient)
                .shadow(color: AppTheme.gold.opacity(0.45), radius: 8)

            Text("Virtual slots · Entertainment only")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)
        }
        .padding(.vertical, 10)
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
