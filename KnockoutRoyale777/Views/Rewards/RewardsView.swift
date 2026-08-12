import SwiftUI

struct RewardsView: View {
    @EnvironmentObject private var store: GameStore
    var onSettings: () -> Void
    @State private var toast: String?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                TopBarView(onSettings: onSettings)

                SectionTitle(text: "DAILY LOGIN REWARDS")

                loginRow

                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(AppTheme.gold)
                    Text("RESETS IN: \(store.resetTimerText)")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                dailyChest

                SectionTitle(text: "DAILY MISSIONS")

                ForEach(GameStore.missions) { mission in
                    MissionRow(mission: mission) {
                        if let reward = store.claimMission(mission.id) {
                            toast = "+\(CoinFormat.compact(reward)) coins"
                        }
                    }
                }

                if let toast {
                    Text(toast)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppTheme.gold)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
        }
        .background(Color.clear)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var loginRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(GameStore.dailyRewards) { reward in
                    let claimed = store.claimedLoginDays.contains(reward.day)
                    let isNext = store.loginDay == reward.day && !claimed
                    let isDay7 = reward.day == 7

                    VStack(spacing: 6) {
                        Text("DAY \(reward.day)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(AppTheme.gold)

                        Image(systemName: reward.icon)
                            .font(.system(size: isDay7 ? 28 : 20))
                            .foregroundStyle(AppTheme.goldGradient)
                            .frame(height: 32)

                        Text(CoinFormat.compact(reward.amount))
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)

                        if claimed {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(AppTheme.emerald)
                        } else if isNext {
                            Text("CLAIM")
                                .font(.system(size: 9, weight: .black))
                                .foregroundStyle(.black)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(AppTheme.goldGradient))
                        } else {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(AppTheme.textMuted)
                        }
                    }
                    .padding(8)
                    .frame(width: isDay7 ? 86 : 68, height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(isDay7 ? AppTheme.gold.opacity(0.18) : Color.black.opacity(0.4))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(isDay7 || isNext ? AppTheme.gold : AppTheme.gold.opacity(0.35), lineWidth: isDay7 ? 2 : 1)
                    )
                    .onTapGesture {
                        if isNext, let amount = store.claimDailyLogin() {
                            toast = "Day \(reward.day): +\(CoinFormat.compact(amount))"
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var dailyChest: some View {
        HStack(spacing: 14) {
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.goldGradient)
                .shadow(color: AppTheme.ruby.opacity(0.5), radius: 12)

            VStack(alignment: .leading, spacing: 8) {
                Text("DAILY BONUS CHEST")
                    .font(.system(size: 15, weight: .black, design: .serif))
                    .foregroundStyle(AppTheme.goldLight)
                Text("Come back every day for bigger rewards!")
                    .font(.system(size: 12))
                    .foregroundStyle(AppTheme.textSecondary)

                GoldButton(
                    title: store.dailyBonusAvailable ? "COLLECT" : "COLLECTED",
                    style: store.dailyBonusAvailable ? .ruby : .muted,
                    compact: true,
                    badge: store.dailyBonusAvailable ? 1 : nil
                ) {
                    if let amount = store.claimDailyBonusChest() {
                        toast = "Chest: +\(CoinFormat.compact(amount))"
                    }
                }
                .disabled(!store.dailyBonusAvailable)
            }
        }
        .padding(14)
        .casinoPanel(cornerRadius: 16)
    }
}

struct MissionRow: View {
    @EnvironmentObject private var store: GameStore
    let mission: MissionDef
    let onClaim: () -> Void

    private var progress: Int { store.missionProgress[mission.id] ?? 0 }
    private var claimed: Bool { store.claimedMissions.contains(mission.id) }
    private var ready: Bool { progress >= mission.target && !claimed }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: mission.icon)
                .font(.system(size: 22))
                .foregroundStyle(AppTheme.gold)
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.4)))

            VStack(alignment: .leading, spacing: 6) {
                Text(mission.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                ProgressView(value: Double(min(progress, mission.target)), total: Double(mission.target))
                    .tint(ready ? AppTheme.emerald : AppTheme.gold)

                Text("\(min(progress, mission.target)) / \(mission.target)")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(AppTheme.textMuted)
            }

            VStack(spacing: 6) {
                HStack(spacing: 3) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .foregroundStyle(AppTheme.gold)
                    Text(CoinFormat.compact(mission.reward))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppTheme.goldLight)
                }

                Button(action: onClaim) {
                    Text(claimed ? "CLAIMED" : "CLAIM")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(claimed ? AppTheme.textMuted : AppTheme.goldLight)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(
                            Capsule().fill(claimed ? Color.white.opacity(0.08) : AppTheme.ruby)
                        )
                        .overlay(Capsule().stroke(AppTheme.gold.opacity(0.5), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .disabled(!ready)
                .opacity(ready || claimed ? 1 : 0.45)
            }
        }
        .padding(12)
        .casinoPanel(cornerRadius: 14)
    }
}
