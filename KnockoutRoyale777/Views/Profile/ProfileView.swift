import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: GameStore
    var onSettings: () -> Void
    @State private var editingName = false
    @State private var nameDraft = ""

    private let achievementColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                TopBarView(onSettings: onSettings)

                identityCard
                statsRow

                SectionTitle(text: "ACHIEVEMENTS")
                LazyVGrid(columns: achievementColumns, spacing: 10) {
                    ForEach(GameStore.achievements) { ach in
                        AchievementCell(achievement: ach)
                    }
                }

                SectionTitle(text: "COLLECTION")
                collectionRow
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
        }
        .background(Color.clear)
        .toolbar(.hidden, for: .navigationBar)
        .alert("Edit Name", isPresented: $editingName) {
            TextField("Name", text: $nameDraft)
            Button("Save") { store.rename(nameDraft) }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var identityCard: some View {
        HStack(spacing: 12) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color.black.opacity(0.5))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(AppTheme.gold)
                    )
                    .overlay(Circle().stroke(AppTheme.gold, lineWidth: 2))

                Image(systemName: "camera.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.black)
                    .padding(5)
                    .background(Circle().fill(AppTheme.gold))
                    .offset(x: 2, y: 2)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(store.displayName)
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundStyle(AppTheme.textPrimary)
                    Button {
                        nameDraft = store.displayName
                        editingName = true
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AppTheme.gold)
                    }
                    .buttonStyle(.plain)
                }

                HStack(spacing: 8) {
                    Text("\(store.level)")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 6).fill(AppTheme.goldGradient))

                    VStack(alignment: .leading, spacing: 3) {
                        ProgressView(value: Double(store.xp), total: Double(max(store.xpToNext, 1)))
                            .tint(AppTheme.gold)
                        Text("\(CoinFormat.string(store.xp)) / \(CoinFormat.string(store.xpToNext)) XP")
                            .font(.system(size: 10, design: .rounded))
                            .foregroundStyle(AppTheme.textMuted)
                    }
                }
            }

            Spacer(minLength: 0)

            VStack(spacing: 4) {
                Image(systemName: "shield.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(AppTheme.goldGradient)
                Text(store.isVIP ? "VIP GOLD" : "ROOKIE")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(AppTheme.gold)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppTheme.purpleGlow.opacity(0.25))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.gold.opacity(0.6), lineWidth: 1)
            )
        }
        .padding(14)
        .casinoPanel(cornerRadius: 16)
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statCell(icon: "arrow.triangle.2.circlepath", title: "TOTAL SPINS", value: CoinFormat.string(store.totalSpins))
            Divider().background(AppTheme.gold.opacity(0.4)).frame(height: 54)
            statCell(icon: "star.circle.fill", title: "BIGGEST WIN", value: CoinFormat.compact(store.biggestWin))
            Divider().background(AppTheme.gold.opacity(0.4)).frame(height: 54)
            statCell(icon: "flame.fill", title: "STREAK", value: "\(store.currentStreakDays) DAYS")
        }
        .padding(.vertical, 12)
        .casinoPanel(cornerRadius: 14)
    }

    private func statCell(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.gold)
            Text(title)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(AppTheme.textMuted)
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.goldLight)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    private var collectionRow: some View {
        HStack(spacing: 10) {
            collectionItem("Glove", "hand.raised.fill", store.collection["glove", default: 0])
            collectionItem("Crown", "crown.fill", store.collection["crown", default: 0])
            collectionItem("777", "7.circle.fill", store.collection["seven", default: 0])
            collectionItem("Chest", "shippingbox.fill", store.collection["chest", default: 0])
        }
    }

    private func collectionItem(_ title: String, _ icon: String, _ count: Int) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(AppTheme.goldGradient)
                .frame(height: 36)
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)
            Text("\(min(count, 1))/1")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(AppTheme.gold)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(Color.black.opacity(0.45)))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .casinoPanel(cornerRadius: 12)
        .opacity(count > 0 ? 1 : 0.55)
    }
}

struct AchievementCell: View {
    @EnvironmentObject private var store: GameStore
    let achievement: AchievementDef

    private var progress: Int { store.achievementProgress[achievement.id] ?? 0 }
    private var unlocked: Bool { store.unlockedAchievements.contains(achievement.id) }

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: achievement.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(AppTheme.goldGradient)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AppTheme.purpleGlow.opacity(0.25)))

                if unlocked {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(AppTheme.emerald)
                        .offset(x: 4, y: -4)
                }
            }

            Text(achievement.title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            if unlocked {
                Text("DONE")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(AppTheme.emerald)
            } else {
                Text("\(min(progress, achievement.target))/\(achievement.target)")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(AppTheme.textMuted)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, minHeight: 96)
        .casinoPanel(cornerRadius: 12)
    }
}
