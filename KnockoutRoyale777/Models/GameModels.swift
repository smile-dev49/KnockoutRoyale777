import Foundation
import SwiftUI

enum ArenaType: String, Codable, CaseIterable, Identifiable {
    case classic
    case tournament
    case megaJackpot
    case vip

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic: return "CLASSIC 777"
        case .tournament: return "KNOCKOUT TOURNAMENT"
        case .megaJackpot: return "MEGA JACKPOT"
        case .vip: return "VIP ARENA"
        }
    }

    var subtitle: String {
        switch self {
        case .classic: return "Spin the reels. Land 777 and win big!"
        case .tournament: return "Compete. Win. Take the Crown. Top scores win virtual prizes!"
        case .megaJackpot: return "High stakes. Higher rewards. Chase the Mega Jackpot!"
        case .vip: return "Exclusive room for high rollers. Bigger bets. Elite rewards."
        }
    }

    var entryCost: Int {
        switch self {
        case .classic: return 10_000
        case .tournament: return 100_000
        case .megaJackpot: return 500_000
        case .vip: return 1_000_000
        }
    }

    var minBet: Int {
        switch self {
        case .classic: return 10_000
        case .tournament: return 50_000
        case .megaJackpot: return 100_000
        case .vip: return 250_000
        }
    }

    var maxBet: Int {
        switch self {
        case .classic: return 1_000_000
        case .tournament: return 2_000_000
        case .megaJackpot: return 5_000_000
        case .vip: return 10_000_000
        }
    }

    var defaultBet: Int { entryCost }

    var betStep: Int {
        switch self {
        case .classic: return 10_000
        case .tournament: return 50_000
        case .megaJackpot: return 100_000
        case .vip: return 250_000
        }
    }

    var winMultiplier: Double {
        switch self {
        case .classic: return 1.0
        case .tournament: return 1.15
        case .megaJackpot: return 1.35
        case .vip: return 1.5
        }
    }

    var badge: String? {
        switch self {
        case .classic: return "POPULAR"
        case .vip: return "VIP ONLY"
        default: return nil
        }
    }

    var iconSystemName: String {
        switch self {
        case .classic: return "7.circle.fill"
        case .tournament: return "trophy.fill"
        case .megaJackpot: return "dollarsign.circle.fill"
        case .vip: return "crown.fill"
        }
    }

    var accent: Color {
        switch self {
        case .classic: return AppTheme.ruby
        case .tournament: return AppTheme.purpleGlow
        case .megaJackpot: return AppTheme.gold
        case .vip: return AppTheme.goldLight
        }
    }
}

enum SlotSymbol: String, CaseIterable, Identifiable, Codable {
    case seven
    case crown
    case glove
    case star
    case chip
    case bell

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .seven: return "777"
        case .crown: return "Crown"
        case .glove: return "Glove"
        case .star: return "Star"
        case .chip: return "Chip"
        case .bell: return "Bell"
        }
    }

    var systemImage: String {
        switch self {
        case .seven: return "7.circle.fill"
        case .crown: return "crown.fill"
        case .glove: return "hand.raised.fill"
        case .star: return "star.fill"
        case .chip: return "circle.circle.fill"
        case .bell: return "bell.fill"
        }
    }

    var tint: Color {
        switch self {
        case .seven: return AppTheme.ruby
        case .crown: return AppTheme.gold
        case .glove: return Color(red: 0.85, green: 0.2, blue: 0.2)
        case .star: return AppTheme.goldLight
        case .chip: return Color(red: 0.2, green: 0.55, blue: 0.95)
        case .bell: return AppTheme.gold
        }
    }

    /// Relative weight for reel strips (higher = more common). Tuned toward ~94% RTP with paytable.
    var weight: Int {
        switch self {
        case .seven: return 4
        case .crown: return 6
        case .glove: return 8
        case .star: return 10
        case .chip: return 12
        case .bell: return 14
        }
    }

    /// Base payout multiplier for 3-of-a-kind on the payline (times bet).
    var triplePayout: Double {
        switch self {
        case .seven: return 50
        case .crown: return 25
        case .glove: return 15
        case .star: return 10
        case .chip: return 6
        case .bell: return 4
        }
    }

    /// Two-of-a-kind (left-aligned or any two matching with wild-less rules: any 2 match).
    var pairPayout: Double {
        switch self {
        case .seven: return 5
        case .crown: return 3
        case .glove: return 2
        case .star: return 1.5
        case .chip: return 1
        case .bell: return 0.5
        }
    }
}

struct JackpotTier: Identifiable {
    let id: String
    let name: String
    let color: Color
    var amount: Int
}

struct AchievementDef: Identifiable, Codable {
    let id: String
    let title: String
    let detail: String
    let icon: String
    let target: Int
}

struct MissionDef: Identifiable, Codable {
    let id: String
    let title: String
    let target: Int
    let reward: Int
    let icon: String
}

struct DailyLoginReward: Identifiable {
    let day: Int
    var id: Int { day }
    let amount: Int
    let icon: String
}

struct SpinResult {
    let reels: [[SlotSymbol]] // 3 reels x 3 rows
    let payline: [SlotSymbol]
    let winAmount: Int
    let isBigWin: Bool
    let description: String
}
