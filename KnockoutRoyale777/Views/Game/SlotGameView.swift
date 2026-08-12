import SwiftUI
import UIKit

struct SlotGameView: View {
    @EnvironmentObject private var store: GameStore
    let arena: ArenaType

    @State private var bet: Int = 0
    @State private var reels: [[SlotSymbol]] = Array(
        repeating: Array(repeating: .bell, count: 3),
        count: 3
    )
    @State private var isSpinning = false
    @State private var autoSpin = false
    @State private var lastWin: Int = 0
    @State private var lastMessage = "GOOD LUCK"
    @State private var showBigWin = false
    @State private var highlightPayline = false
    @State private var turbo = false
    @Environment(\.dismiss) private var dismiss

    private let spinColumns = 3

    var body: some View {
        VStack(spacing: 10) {
            TopBarView()

            jackpotStrip

            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppTheme.panel)
                    .goldStroke(cornerRadius: 18, lineWidth: 2)

                VStack(spacing: 8) {
                    if showBigWin {
                        Text("BIG WIN")
                            .font(.system(size: 22, weight: .black, design: .serif))
                            .foregroundStyle(AppTheme.goldGradient)
                            .shadow(color: AppTheme.gold.opacity(0.7), radius: 8)
                            .transition(.scale.combined(with: .opacity))
                    }

                    HStack(spacing: 8) {
                        ForEach(0..<spinColumns, id: \.self) { col in
                            VStack(spacing: 6) {
                                ForEach(0..<3, id: \.self) { row in
                                    SymbolTile(
                                        symbol: reels[col][row],
                                        highlighted: highlightPayline && row == 1
                                    )
                                    .rotation3DEffect(
                                        .degrees(isSpinning ? 360 : 0),
                                        axis: (x: 1, y: 0, z: 0)
                                    )
                                    .animation(
                                        isSpinning
                                            ? .linear(duration: turbo ? 0.15 : 0.35).repeatCount(turbo ? 2 : 4, autoreverses: false)
                                            : .easeOut(duration: 0.25),
                                        value: isSpinning
                                    )
                                }
                            }
                        }

                        VStack(spacing: 0) {
                            Circle()
                                .fill(AppTheme.goldGradient)
                                .frame(width: 22, height: 22)
                            Capsule()
                                .fill(AppTheme.gold)
                                .frame(width: 8, height: 72)
                        }
                        .padding(.leading, 4)
                        .shadow(color: AppTheme.gold.opacity(0.4), radius: 4)
                    }
                    .padding(.horizontal, 14)
                }
                .padding(.vertical, 14)
            }
            .padding(.horizontal, 16)
            .frame(height: 280)

            winBanner

            Text("RECENT: \(lastMessage)")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, 16)

            if arena == .tournament {
                Text("TOURNAMENT SCORE: \(CoinFormat.string(store.tournamentScore))")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(AppTheme.purpleGlow)
            }

            controls
                .padding(.horizontal, 16)

            Spacer(minLength: 0)
        }
        .background(Color.clear)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    autoSpin = false
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(AppTheme.gold)
                }
            }
            ToolbarItem(placement: .principal) {
                Text(arena.title)
                    .font(.system(size: 13, weight: .bold, design: .serif))
                    .foregroundStyle(AppTheme.gold)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            if bet == 0 {
                bet = min(max(arena.defaultBet, arena.minBet), arena.maxBet)
                bet = min(bet, store.coins)
                bet = max(bet, arena.minBet)
            }
        }
        .onChange(of: autoSpin) { _, enabled in
            if enabled { Task { await runAutoSpinLoop() } }
        }
    }

    private var jackpotStrip: some View {
        HStack(spacing: 4) {
            jackpotCell("GRAND", store.jackpotGrand, AppTheme.ruby)
            jackpotCell("MAJOR", store.jackpotMajor, AppTheme.purpleGlow)
            jackpotCell("MINOR", store.jackpotMinor, Color.blue)
            jackpotCell("MINI", store.jackpotMini, AppTheme.emerald)
        }
        .padding(.horizontal, 12)
    }

    private func jackpotCell(_ title: String, _ amount: Int, _ color: Color) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)
            Text(CoinFormat.compact(amount))
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.goldLight)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.black.opacity(0.45)))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(color.opacity(0.5), lineWidth: 1))
    }

    private var winBanner: some View {
        VStack(spacing: 2) {
            Text("YOU WON")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppTheme.gold)
            Text(CoinFormat.string(lastWin))
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.goldGradient)
                .shadow(color: AppTheme.gold.opacity(0.4), radius: 6)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(AppTheme.rubyDeep.opacity(0.85))
                .overlay(Capsule().stroke(AppTheme.gold.opacity(0.7), lineWidth: 1.2))
        )
        .padding(.horizontal, 24)
    }

    private var controls: some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 10) {
                Button {
                    // paytable hint
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(AppTheme.gold)
                        .font(.system(size: 20))
                }
                .opacity(0.3)
                .disabled(true)

                betControl

                VStack(spacing: 8) {
                    miniAction("AUTO SPIN", icon: "arrow.triangle.2.circlepath") {
                        autoSpin.toggle()
                    }
                    .opacity(autoSpin ? 1 : 0.85)
                    .overlay(
                        Capsule().stroke(autoSpin ? AppTheme.emerald : Color.clear, lineWidth: 2)
                    )

                    miniAction("MAX BET", icon: "bitcoinsign.circle.fill") {
                        bet = min(arena.maxBet, store.coins)
                    }
                }
                .frame(width: 110)
            }

            Button {
                Task { await spinOnce(fromHold: false) }
            } label: {
                VStack(spacing: 2) {
                    Text("SPIN")
                        .font(.system(size: 24, weight: .black, design: .serif))
                    Text(turbo ? "TURBO ON" : "HOLD FOR TURBO")
                        .font(.system(size: 9, weight: .semibold))
                }
                .foregroundStyle(AppTheme.goldLight)
                .frame(width: 120, height: 120)
                .background(
                    Circle().fill(AppTheme.rubyGradient)
                )
                .overlay(
                    Circle().stroke(AppTheme.gold, lineWidth: 4)
                )
                .shadow(color: AppTheme.ruby.opacity(0.5), radius: 14)
            }
            .buttonStyle(.plain)
            .disabled(isSpinning || store.coins < bet)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.45).onEnded { _ in
                    turbo.toggle()
                }
            )
        }
    }

    private var betControl: some View {
        HStack(spacing: 10) {
            Button {
                bet = max(arena.minBet, bet - arena.betStep)
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.gold)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(Color.black.opacity(0.5)))
            }
            .buttonStyle(.plain)

            VStack(spacing: 1) {
                Text("TOTAL BET")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(AppTheme.textMuted)
                Text(CoinFormat.string(bet))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.goldLight)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)

            Button {
                bet = min(min(arena.maxBet, store.coins), bet + arena.betStep)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.gold)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(Color.black.opacity(0.5)))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.black.opacity(0.45)))
        .overlay(Capsule().stroke(AppTheme.gold.opacity(0.6), lineWidth: 1))
    }

    private func miniAction(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(AppTheme.goldLight)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Capsule().fill(Color.black.opacity(0.5)))
            .overlay(Capsule().stroke(AppTheme.gold.opacity(0.55), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    @MainActor
    private func spinOnce(fromHold: Bool) async {
        guard !isSpinning else { return }
        guard store.canAfford(bet) else {
            autoSpin = false
            lastMessage = "NOT ENOUGH COINS"
            return
        }

        isSpinning = true
        highlightPayline = false
        showBigWin = false
        lastWin = 0

        let delay = turbo ? 0.35 : 0.85
        try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

        if let result = store.performSpin(bet: bet, arena: arena) {
            reels = result.reels
            lastWin = result.winAmount
            lastMessage = result.description
            highlightPayline = result.winAmount > 0
            showBigWin = result.isBigWin
            UIImpactFeedbackGenerator(style: result.isBigWin ? .heavy : .light).impactOccurred()
        }

        isSpinning = false
    }

    @MainActor
    private func runAutoSpinLoop() async {
        while autoSpin {
            await spinOnce(fromHold: false)
            if !autoSpin { break }
            try? await Task.sleep(nanoseconds: UInt64((turbo ? 0.25 : 0.55) * 1_000_000_000))
            if store.coins < bet {
                autoSpin = false
                lastMessage = "AUTO STOPPED — LOW BALANCE"
            }
        }
    }
}
