import Foundation
import SwiftUI
import Combine

@MainActor
final class GameStore: ObservableObject {
    // MARK: - Player economy
    @Published var coins: Int
    @Published var displayName: String
    @Published var level: Int
    @Published var xp: Int
    @Published var xpToNext: Int
    @Published var isVIP: Bool

    // MARK: - Stats
    @Published var totalSpins: Int
    @Published var biggestWin: Int
    @Published var currentStreakDays: Int
    @Published var lastPlayDayKey: String

    // MARK: - Jackpots (virtual progressive)
    @Published var jackpotGrand: Int
    @Published var jackpotMajor: Int
    @Published var jackpotMinor: Int
    @Published var jackpotMini: Int

    // MARK: - Daily login
    @Published var loginDay: Int // 1...7 progress (next claimable day index 1-based claimed count)
    @Published var claimedLoginDays: Set<Int>
    @Published var lastLoginClaimDate: Date?
    @Published var dailyBonusAvailable: Bool
    @Published var lastDailyBonusDate: Date?

    // MARK: - Missions
    @Published var missionProgress: [String: Int]
    @Published var claimedMissions: Set<String>
    @Published var missionDayKey: String

    // MARK: - Achievements
    @Published var achievementProgress: [String: Int]
    @Published var unlockedAchievements: Set<String>

    // MARK: - Collection counts
    @Published var collection: [String: Int]

    // MARK: - Tournament (virtual score)
    @Published var tournamentScore: Int
    @Published var tournamentBest: Int

    private let defaults = UserDefaults.standard
    private let engine = SlotEngine()
    private let keys = StorageKeys.self

    static let startingCoins = 1_000_000

    static let dailyRewards: [DailyLoginReward] = [
        .init(day: 1, amount: 50_000, icon: "bitcoinsign.circle.fill"),
        .init(day: 2, amount: 75_000, icon: "bitcoinsign.circle.fill"),
        .init(day: 3, amount: 100_000, icon: "circle.circle.fill"),
        .init(day: 4, amount: 150_000, icon: "crown.fill"),
        .init(day: 5, amount: 200_000, icon: "star.fill"),
        .init(day: 6, amount: 300_000, icon: "trophy.fill"),
        .init(day: 7, amount: 500_000, icon: "crown.fill")
    ]

    static let missions: [MissionDef] = [
        .init(id: "spin20", title: "Spin 20 times", target: 20, reward: 20_000, icon: "arrow.triangle.2.circlepath"),
        .init(id: "win3", title: "Win 3 spins", target: 3, reward: 30_000, icon: "crown.fill"),
        .init(id: "login", title: "Open the app today", target: 1, reward: 10_000, icon: "calendar")
    ]

    static let achievements: [AchievementDef] = [
        .init(id: "first_spin", title: "First Bell", detail: "Spin once", icon: "hand.raised.fill", target: 1),
        .init(id: "spins_100", title: "Warm Up", detail: "100 total spins", icon: "flame.fill", target: 100),
        .init(id: "spins_1000", title: "Ring Veteran", detail: "1,000 spins", icon: "bolt.fill", target: 1_000),
        .init(id: "seven_hit", title: "Lucky 777", detail: "Land triple 7s", icon: "7.circle.fill", target: 1),
        .init(id: "big_win", title: "Big Winner", detail: "Win 10× bet", icon: "star.fill", target: 1),
        .init(id: "chest", title: "Chest Hunter", detail: "Collect daily bonus 5×", icon: "shippingbox.fill", target: 5),
        .init(id: "level_10", title: "Contender", detail: "Reach level 10", icon: "shield.fill", target: 10),
        .init(id: "champion", title: "Champion", detail: "Reach level 50", icon: "trophy.fill", target: 50)
    ]

    init() {
        coins = defaults.object(forKey: keys.coins) as? Int ?? Self.startingCoins
        displayName = defaults.string(forKey: keys.displayName) ?? "BoxingChamp"
        level = defaults.object(forKey: keys.level) as? Int ?? 1
        xp = defaults.object(forKey: keys.xp) as? Int ?? 0
        xpToNext = defaults.object(forKey: keys.xpToNext) as? Int ?? 1_000
        isVIP = defaults.bool(forKey: keys.isVIP)

        totalSpins = defaults.integer(forKey: keys.totalSpins)
        biggestWin = defaults.integer(forKey: keys.biggestWin)
        currentStreakDays = max(1, defaults.integer(forKey: keys.streak))
        lastPlayDayKey = defaults.string(forKey: keys.lastPlayDay) ?? ""

        jackpotGrand = defaults.object(forKey: keys.jGrand) as? Int ?? 250_000_000
        jackpotMajor = defaults.object(forKey: keys.jMajor) as? Int ?? 50_000_000
        jackpotMinor = defaults.object(forKey: keys.jMinor) as? Int ?? 10_000_000
        jackpotMini = defaults.object(forKey: keys.jMini) as? Int ?? 2_000_000

        loginDay = defaults.object(forKey: keys.loginDay) as? Int ?? 1
        claimedLoginDays = Set(defaults.array(forKey: keys.claimedLogin) as? [Int] ?? [])
        lastLoginClaimDate = defaults.object(forKey: keys.lastLoginClaim) as? Date
        dailyBonusAvailable = defaults.object(forKey: keys.dailyBonusAvail) as? Bool ?? true
        lastDailyBonusDate = defaults.object(forKey: keys.lastDailyBonus) as? Date

        missionProgress = Self.intDictionary(defaults.dictionary(forKey: keys.missionProgress))
        claimedMissions = Set(defaults.array(forKey: keys.claimedMissions) as? [String] ?? [])
        missionDayKey = defaults.string(forKey: keys.missionDay) ?? ""

        achievementProgress = Self.intDictionary(defaults.dictionary(forKey: keys.achProgress))
        unlockedAchievements = Set(defaults.array(forKey: keys.achUnlocked) as? [String] ?? [])
        collection = Self.intDictionary(defaults.dictionary(forKey: keys.collection))
        if collection.isEmpty {
            collection = ["glove": 0, "crown": 0, "seven": 0, "chest": 0]
        }

        tournamentScore = defaults.integer(forKey: keys.tournamentScore)
        tournamentBest = defaults.integer(forKey: keys.tournamentBest)

        refreshDailyState()
        bumpMission(id: "login", by: 1)
        checkAchievements()
        persist()
    }

    // MARK: - Daily timers

    var secondsUntilReset: Int {
        let cal = Calendar.current
        let now = Date()
        let tomorrow = cal.startOfDay(for: cal.date(byAdding: .day, value: 1, to: now)!)
        return max(0, Int(tomorrow.timeIntervalSince(now)))
    }

    var resetTimerText: String {
        let s = secondsUntilReset
        let h = s / 3600
        let m = (s % 3600) / 60
        let sec = s % 60
        return String(format: "%02d:%02d:%02d", h, m, sec)
    }

    func refreshDailyState() {
        let today = dayKey(Date())
        if missionDayKey != today {
            missionDayKey = today
            missionProgress = ["login": 1]
            claimedMissions = []
        }

        if let last = lastDailyBonusDate, dayKey(last) == today {
            dailyBonusAvailable = false
        } else if lastDailyBonusDate == nil {
            dailyBonusAvailable = true
        } else {
            dailyBonusAvailable = true
        }

        updateStreakIfNeeded()
    }

    private func updateStreakIfNeeded() {
        let today = dayKey(Date())
        guard lastPlayDayKey != today else { return }
        if lastPlayDayKey.isEmpty {
            currentStreakDays = 1
        } else if let last = dateFromDayKey(lastPlayDayKey),
                  let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()),
                  dayKey(last) == dayKey(yesterday) {
            currentStreakDays += 1
        } else if lastPlayDayKey != today {
            currentStreakDays = 1
        }
        lastPlayDayKey = today
    }

    // MARK: - Economy actions

    func canAfford(_ amount: Int) -> Bool { coins >= amount }

    @discardableResult
    func spend(_ amount: Int) -> Bool {
        guard coins >= amount else { return false }
        coins -= amount
        persist()
        return true
    }

    func credit(_ amount: Int) {
        guard amount > 0 else { return }
        coins += amount
        if amount > biggestWin { biggestWin = amount }
        persist()
    }

    func claimDailyLogin() -> Int? {
        refreshDailyState()
        if let last = lastLoginClaimDate, dayKey(last) == dayKey(Date()) {
            return nil
        }
        let day = min(max(loginDay, 1), 7)
        guard !claimedLoginDays.contains(day) else { return nil }
        let reward = Self.dailyRewards.first(where: { $0.day == day })?.amount ?? 50_000
        claimedLoginDays.insert(day)
        lastLoginClaimDate = Date()
        credit(reward)
        if day >= 7 {
            loginDay = 1
            claimedLoginDays = []
        } else {
            loginDay = day + 1
        }
        bumpCollection("chest")
        persist()
        return reward
    }

    func claimDailyBonusChest() -> Int? {
        refreshDailyState()
        guard dailyBonusAvailable else { return nil }
        let reward = 100_000 + (currentStreakDays * 5_000)
        dailyBonusAvailable = false
        lastDailyBonusDate = Date()
        credit(reward)
        bumpAchievement("chest", to: (achievementProgress["chest"] ?? 0) + 1)
        bumpCollection("chest")
        persist()
        return reward
    }

    func claimMission(_ id: String) -> Int? {
        guard let mission = Self.missions.first(where: { $0.id == id }) else { return nil }
        guard !claimedMissions.contains(id) else { return nil }
        let progress = missionProgress[id] ?? 0
        guard progress >= mission.target else { return nil }
        claimedMissions.insert(id)
        credit(mission.reward)
        persist()
        return mission.reward
    }

    // MARK: - Spin

    func performSpin(bet: Int, arena: ArenaType) -> SpinResult? {
        refreshDailyState()
        guard spend(bet) else { return nil }

        // Feed virtual jackpots a tiny bit each spin
        jackpotMini += max(1, bet / 500)
        jackpotMinor += max(1, bet / 200)
        jackpotMajor += max(1, bet / 80)
        jackpotGrand += max(1, bet / 40)

        var result = engine.spin(bet: bet, arena: arena)

        // Rare jackpot hits (virtual only)
        let roll = Int.random(in: 1...10_000)
        if roll == 1 {
            let hit = jackpotGrand
            jackpotGrand = 250_000_000
            result = SpinResult(
                reels: result.reels,
                payline: [.seven, .seven, .seven],
                winAmount: hit,
                isBigWin: true,
                description: "GRAND JACKPOT!"
            )
        } else if roll <= 4 {
            let hit = jackpotMini
            jackpotMini = 2_000_000
            result = SpinResult(
                reels: result.reels,
                payline: result.payline,
                winAmount: result.winAmount + hit,
                isBigWin: true,
                description: "MINI JACKPOT + \(result.description)"
            )
        }

        if result.winAmount > 0 {
            credit(result.winAmount)
            bumpMission(id: "win3", by: 1)
        }

        totalSpins += 1
        addXP(10 + min(50, bet / 50_000))
        bumpMission(id: "spin20", by: 1)
        bumpAchievement("first_spin", to: 1)
        bumpAchievement("spins_100", to: totalSpins)
        bumpAchievement("spins_1000", to: totalSpins)

        if result.payline.allSatisfy({ $0 == .seven }) {
            bumpAchievement("seven_hit", to: 1)
            bumpCollection("seven")
        }
        if result.isBigWin {
            bumpAchievement("big_win", to: 1)
        }
        if result.payline.contains(.crown) { bumpCollection("crown") }
        if result.payline.contains(.glove) { bumpCollection("glove") }

        if arena == .tournament {
            tournamentScore += result.winAmount
            tournamentBest = max(tournamentBest, result.winAmount)
        }

        if level >= 20 { isVIP = true }
        updateStreakIfNeeded()
        checkAchievements()
        persist()
        return result
    }

    func addXP(_ amount: Int) {
        xp += amount
        while xp >= xpToNext {
            xp -= xpToNext
            level += 1
            xpToNext = 1_000 + (level - 1) * 750
            credit(25_000) // level-up bonus virtual coins
        }
        bumpAchievement("level_10", to: level)
        bumpAchievement("champion", to: level)
    }

    private func bumpMission(id: String, by: Int) {
        let current = missionProgress[id] ?? 0
        if let mission = Self.missions.first(where: { $0.id == id }) {
            missionProgress[id] = min(mission.target, current + by)
        } else {
            missionProgress[id] = current + by
        }
    }

    private func bumpAchievement(_ id: String, to value: Int) {
        let prev = achievementProgress[id] ?? 0
        achievementProgress[id] = max(prev, value)
    }

    private func bumpCollection(_ key: String) {
        collection[key, default: 0] += 1
    }

    private func checkAchievements() {
        for def in Self.achievements {
            let progress = achievementProgress[def.id] ?? 0
            if progress >= def.target {
                unlockedAchievements.insert(def.id)
            }
        }
    }

    func rename(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        displayName = String(trimmed.prefix(16))
        persist()
    }

    func resetProgressForDebug() {
        coins = Self.startingCoins
        totalSpins = 0
        biggestWin = 0
        level = 1
        xp = 0
        xpToNext = 1_000
        persist()
    }

    // MARK: - Persistence

    func persist() {
        defaults.set(coins, forKey: keys.coins)
        defaults.set(displayName, forKey: keys.displayName)
        defaults.set(level, forKey: keys.level)
        defaults.set(xp, forKey: keys.xp)
        defaults.set(xpToNext, forKey: keys.xpToNext)
        defaults.set(isVIP, forKey: keys.isVIP)
        defaults.set(totalSpins, forKey: keys.totalSpins)
        defaults.set(biggestWin, forKey: keys.biggestWin)
        defaults.set(currentStreakDays, forKey: keys.streak)
        defaults.set(lastPlayDayKey, forKey: keys.lastPlayDay)
        defaults.set(jackpotGrand, forKey: keys.jGrand)
        defaults.set(jackpotMajor, forKey: keys.jMajor)
        defaults.set(jackpotMinor, forKey: keys.jMinor)
        defaults.set(jackpotMini, forKey: keys.jMini)
        defaults.set(loginDay, forKey: keys.loginDay)
        defaults.set(Array(claimedLoginDays), forKey: keys.claimedLogin)
        defaults.set(lastLoginClaimDate, forKey: keys.lastLoginClaim)
        defaults.set(dailyBonusAvailable, forKey: keys.dailyBonusAvail)
        defaults.set(lastDailyBonusDate, forKey: keys.lastDailyBonus)
        defaults.set(missionProgress, forKey: keys.missionProgress)
        defaults.set(Array(claimedMissions), forKey: keys.claimedMissions)
        defaults.set(missionDayKey, forKey: keys.missionDay)
        defaults.set(achievementProgress, forKey: keys.achProgress)
        defaults.set(Array(unlockedAchievements), forKey: keys.achUnlocked)
        defaults.set(collection, forKey: keys.collection)
        defaults.set(tournamentScore, forKey: keys.tournamentScore)
        defaults.set(tournamentBest, forKey: keys.tournamentBest)
    }

    private func dayKey(_ date: Date) -> String {
        let f = DateFormatter()
        f.calendar = Calendar.current
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private func dateFromDayKey(_ key: String) -> Date? {
        let f = DateFormatter()
        f.calendar = Calendar.current
        f.dateFormat = "yyyy-MM-dd"
        return f.date(from: key)
    }

    private static func intDictionary(_ raw: [String: Any]?) -> [String: Int] {
        guard let raw else { return [:] }
        var result: [String: Int] = [:]
        for (key, value) in raw {
            if let i = value as? Int {
                result[key] = i
            } else if let n = value as? NSNumber {
                result[key] = n.intValue
            }
        }
        return result
    }
}

private enum StorageKeys {
    static let coins = "kr.coins"
    static let displayName = "kr.name"
    static let level = "kr.level"
    static let xp = "kr.xp"
    static let xpToNext = "kr.xpToNext"
    static let isVIP = "kr.vip"
    static let totalSpins = "kr.spins"
    static let biggestWin = "kr.biggest"
    static let streak = "kr.streak"
    static let lastPlayDay = "kr.lastPlay"
    static let jGrand = "kr.jg"
    static let jMajor = "kr.jma"
    static let jMinor = "kr.jmi"
    static let jMini = "kr.jmn"
    static let loginDay = "kr.loginDay"
    static let claimedLogin = "kr.claimedLogin"
    static let lastLoginClaim = "kr.lastLogin"
    static let dailyBonusAvail = "kr.bonusAvail"
    static let lastDailyBonus = "kr.lastBonus"
    static let missionProgress = "kr.missions"
    static let claimedMissions = "kr.claimedM"
    static let missionDay = "kr.missionDay"
    static let achProgress = "kr.achP"
    static let achUnlocked = "kr.achU"
    static let collection = "kr.collect"
    static let tournamentScore = "kr.tScore"
    static let tournamentBest = "kr.tBest"
}
