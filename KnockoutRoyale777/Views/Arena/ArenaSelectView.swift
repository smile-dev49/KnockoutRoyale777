import SwiftUI

struct ArenaSelectView: View {
    @EnvironmentObject private var store: GameStore
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                TopBarView()

                SectionTitle(text: "CHOOSE YOUR ARENA")
                    .padding(.top, 4)

                ForEach(ArenaType.allCases) { arena in
                    ArenaCard(arena: arena) {
                        path.append(arena)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 28)
        }
        .background(Color.clear)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    path.removeLast()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(AppTheme.gold)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

struct ArenaCard: View {
    @EnvironmentObject private var store: GameStore
    let arena: ArenaType
    let onPlay: () -> Void

    private var canEnter: Bool { store.canAfford(arena.minBet) }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(arena.accent.opacity(0.22))
                Image(systemName: arena.iconSystemName)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(AppTheme.goldGradient)
                    .shadow(color: arena.accent.opacity(0.6), radius: 10)
            }
            .frame(width: 88, height: 100)

            VStack(alignment: .leading, spacing: 6) {
                if let badge = arena.badge {
                    Text(badge)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(arena == .vip ? AppTheme.purpleGlow : AppTheme.ruby))
                }

                Text(arena.title)
                    .font(.system(size: 15, weight: .black, design: .serif))
                    .foregroundStyle(AppTheme.goldLight)

                Text(arena.subtitle)
                    .font(.system(size: 11))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(arena == .vip ? "MIN. ENTRY" : "ENTRY COST")
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundStyle(AppTheme.textMuted)
                        HStack(spacing: 4) {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .foregroundStyle(AppTheme.gold)
                                .font(.system(size: 12))
                            Text(CoinFormat.string(arena.entryCost))
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.goldLight)
                        }
                    }

                    Spacer()

                    Button(action: onPlay) {
                        Text(canEnter ? (arena == .tournament || arena == .vip ? "SELECT" : "PLAY") : "LOCKED")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(canEnter ? AppTheme.goldLight : AppTheme.textMuted)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule().fill(canEnter ? AnyShapeStyle(AppTheme.rubyGradient) : AnyShapeStyle(Color.white.opacity(0.08)))
                            )
                            .overlay(Capsule().stroke(AppTheme.gold.opacity(0.7), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .disabled(!canEnter)
                }
            }
        }
        .padding(12)
        .casinoPanel(cornerRadius: 16)
        .opacity(canEnter ? 1 : 0.7)
    }
}
