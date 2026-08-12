import Foundation

/// Local slot math aimed near ~94% RTP (entertainment simulation only).
struct SlotEngine {
    private let strip: [SlotSymbol]

    init() {
        var built: [SlotSymbol] = []
        for symbol in SlotSymbol.allCases {
            built.append(contentsOf: Array(repeating: symbol, count: symbol.weight))
        }
        strip = built
    }

    func spin(bet: Int, arena: ArenaType) -> SpinResult {
        let reels: [[SlotSymbol]] = (0..<3).map { _ in
            (0..<3).map { _ in strip.randomElement()! }
        }
        let payline = [reels[0][1], reels[1][1], reels[2][1]]
        let (raw, description) = evaluate(payline: payline)
        let scaled = Int((Double(bet) * raw * arena.winMultiplier).rounded())
        let isBigWin = scaled >= bet * 10
        return SpinResult(
            reels: reels,
            payline: payline,
            winAmount: scaled,
            isBigWin: isBigWin,
            description: description
        )
    }

    private func evaluate(payline: [SlotSymbol]) -> (Double, String) {
        let a = payline[0], b = payline[1], c = payline[2]

        if a == b && b == c {
            return (a.triplePayout, "\(a.displayName) LINE PAYS ×\(Int(a.triplePayout))")
        }

        // Best pair among the three
        if a == b {
            return (a.pairPayout, "\(a.displayName) PAIR PAYS ×\(format(a.pairPayout))")
        }
        if b == c {
            return (b.pairPayout, "\(b.displayName) PAIR PAYS ×\(format(b.pairPayout))")
        }
        if a == c {
            return (a.pairPayout * 0.75, "\(a.displayName) SPLIT PAYS ×\(format(a.pairPayout * 0.75))")
        }

        return (0, "NO WIN")
    }

    private func format(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(value))"
            : String(format: "%.1f", value)
    }
}
