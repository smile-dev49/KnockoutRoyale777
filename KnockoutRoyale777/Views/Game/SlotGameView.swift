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
    @State private var showMaxBetConfirm = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion

    private let spinColumns = 3
    private var motionReduced: Bool { store.reduceMotionInGame || systemReduceMotion }

    var body: some View {
        GeometryReader { geo in
            let metrics = LayoutMetrics(size: geo.size)

            VStack(spacing: metrics.spacing) {
                TopBarView()

                jackpotStrip

                reelBoard(height: metrics.reelHeight)

                winBanner(compact: metrics.compact)

                Text("RECENT: \(lastMessage)")
                    .font(.system(size: metrics.compact ? 10 : 11, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .padding(.horizontal, 16)

                if arena == .tournament {
                    Text("TOURNAMENT SCORE: \(CoinFormat.string(store.tournamentScore))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppTheme.purpleGlow)
                }

                controls(spinSize: metrics.spinSize, compact: metrics.compact)
                    .padding(.horizontal, 12)

                Spacer(minLength: 0)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
        }
        .appScreenBackground()
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
            turbo = store.defaultTurboEnabled
            if bet == 0 {
                bet = min(max(arena.defaultBet, arena.minBet), arena.maxBet)
                bet = min(bet, store.coins)
                bet = max(bet, arena.minBet)
            }
        }
        .onChange(of: autoSpin) { _, enabled in
            if enabled { Task { await runAutoSpinLoop() } }
        }
        .alert("Max Bet?", isPresented: $showMaxBetConfirm) {
            Button("Set Max Bet") { applyMaxBet() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Set your total bet to \(CoinFormat.string(min(arena.maxBet, store.coins))) virtual coins?")
        }
    }

    private func applyMaxBet() {
        bet = min(arena.maxBet, store.coins)
    }

    private struct LayoutMetrics {
        let spacing: CGFloat
        let reelHeight: CGFloat
        let spinSize: CGFloat
        let compact: Bool

        init(size: CGSize) {
            let h = size.height
            let w = size.width
            compact = h < 720 || w < 380
            spacing = compact ? 6 : 10
            // Keep reels dominant but leave room for controls + spin on short screens.
            reelHeight = min(compact ? 210 : 260, max(160, h * 0.34))
            spinSize = min(compact ? 92 : 108, max(76, min(w * 0.24, h * 0.14)))
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

    private func reelBoard(height: CGFloat) -> some View {
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
                                    .degrees(!motionReduced && isSpinning ? 360 : 0),
                                    axis: (x: 1, y: 0, z: 0)
                                )
                                .animation(
                                    motionReduced
                                        ? nil
                                        : (isSpinning
                                            ? .linear(duration: turbo ? 0.15 : 0.35).repeatCount(turbo ? 2 : 4, autoreverses: false)
                                            : .easeOut(duration: 0.25)),
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
                            .frame(width: 8, height: max(48, height * 0.28))
                    }
                    .padding(.leading, 4)
                    .shadow(color: AppTheme.gold.opacity(0.4), radius: 4)
                }
                .padding(.horizontal, 14)
            }
            .padding(.vertical, 12)
        }
        .padding(.horizontal, 16)
        .frame(height: height)
    }

    private func winBanner(compact: Bool) -> some View {
        VStack(spacing: 2) {
            Text("YOU WON")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(AppTheme.gold)
            Text(CoinFormat.string(lastWin))
                .font(.system(size: compact ? 22 : 28, weight: .black, design: .rounded))
                .foregroundStyle(AppTheme.goldGradient)
                .shadow(color: AppTheme.gold.opacity(0.4), radius: 6)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, compact ? 6 : 10)
        .background(
            Capsule()
                .fill(AppTheme.rubyDeep.opacity(0.85))
                .overlay(Capsule().stroke(AppTheme.gold.opacity(0.7), lineWidth: 1.2))
        )
        .padding(.horizontal, 24)
    }

    private func controls(spinSize: CGFloat, compact: Bool) -> some View {
        HStack(alignment: .center, spacing: compact ? 8 : 12) {
            VStack(spacing: 8) {
                betControl
                HStack(spacing: 8) {
                    miniAction("AUTO", icon: "arrow.triangle.2.circlepath") {
                        autoSpin.toggle()
                    }
                    .opacity(autoSpin ? 1 : 0.85)
                    .overlay(
                        Capsule().stroke(autoSpin ? AppTheme.emerald : Color.clear, lineWidth: 2)
                    )

                    miniAction("MAX", icon: "bitcoinsign.circle.fill") {
                        if store.confirmMaxBet {
                            showMaxBetConfirm = true
                        } else {
                            applyMaxBet()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)

            Button {
                Task { await spinOnce(fromHold: false) }
            } label: {
                VStack(spacing: 2) {
                    Text("SPIN")
                        .font(.system(size: spinSize * 0.22, weight: .black, design: .serif))
                    Text(turbo ? "TURBO ON" : "HOLD FOR TURBO")
                        .font(.system(size: max(8, spinSize * 0.08), weight: .semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .foregroundStyle(AppTheme.goldLight)
                .frame(width: spinSize, height: spinSize)
                .background(Circle().fill(AppTheme.rubyGradient))
                .overlay(Circle().stroke(AppTheme.gold, lineWidth: 4))
                .shadow(color: AppTheme.ruby.opacity(0.5), radius: 14)
            }
            .buttonStyle(.plain)
            .disabled(isSpinning || store.coins < bet)
            .accessibilityLabel("Spin")
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.45).onEnded { _ in
                    turbo.toggle()
                }
            )
        }
        .padding(.vertical, 4)
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
            if store.hapticsEnabled {
                UIImpactFeedbackGenerator(style: result.isBigWin ? .heavy : .light).impactOccurred()
            }
            if result.isBigWin && store.stopAutoOnBigWin {
                autoSpin = false
                lastMessage = "\(result.description) · AUTO STOPPED"
            }
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
