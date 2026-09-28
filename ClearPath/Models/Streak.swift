import Foundation

// MARK: - Streak Model
struct Streak: Codable, Equatable {
    var currentStreak: Int
    var bestStreak: Int
    var streakShields: Int
    var lastActivityDate: Date?
    var activityCalendar: [Date: DayStatus]
    var lastRepairDate: Date?
    var isFirstStreakReset: Bool

    init(
        currentStreak: Int = 0,
        bestStreak: Int = 0,
        streakShields: Int = 0,
        lastActivityDate: Date? = nil,
        activityCalendar: [Date: DayStatus] = [:],
        lastRepairDate: Date? = nil,
        isFirstStreakReset: Bool = true
    ) {
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.streakShields = streakShields
        self.lastActivityDate = lastActivityDate
        self.activityCalendar = activityCalendar
        self.lastRepairDate = lastRepairDate
        self.isFirstStreakReset = isFirstStreakReset
    }

    // Maximum shields that can be held
    static let maxShields = 2

    // Days required to earn a shield
    static let daysPerShield = 10

    // Milestone days
    static let milestones = [7, 30, 100, 365]

    var hasActivityToday: Bool {
        guard let lastDate = lastActivityDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }

    var canRepairStreak: Bool {
        guard let lastRepair = lastRepairDate else { return true }
        let daysSinceRepair = Calendar.current.dateComponents([.day], from: lastRepair, to: Date()).day ?? 0
        return daysSinceRepair >= 30
    }

    var isAtMilestone: Bool {
        Self.milestones.contains(currentStreak)
    }

    mutating func recordActivity() {
        guard !hasActivityToday else { return }

        let today = Calendar.current.startOfDay(for: Date())
        activityCalendar[today] = .completed

        currentStreak += 1
        if currentStreak > bestStreak {
            bestStreak = currentStreak
        }

        // Check if earned a new shield
        if currentStreak > 0 && currentStreak % Self.daysPerShield == 0 && streakShields < Self.maxShields {
            streakShields += 1
        }

        lastActivityDate = Date()
    }

    mutating func consumeShield() -> Bool {
        guard streakShields > 0 else { return false }
        streakShields -= 1

        let today = Calendar.current.startOfDay(for: Date())
        activityCalendar[today] = .shielded

        return true
    }

    mutating func repairYesterday() -> Bool {
        guard canRepairStreak else { return false }

        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Calendar.current.startOfDay(for: Date()))!
        activityCalendar[yesterday] = .repaired
        lastRepairDate = Date()

        // Don't break the streak
        return true
    }

    mutating func resetStreak() {
        currentStreak = 0
        // Best streak is never reset
    }
}

// MARK: - Day Status
enum DayStatus: String, Codable {
    case completed  // Normal completion
    case shielded   // Protected by shield
    case repaired   // Fixed with repair
    case missed     // No activity, no protection
}

// MARK: - Streak Milestone
struct StreakMilestone: Identifiable {
    let id = UUID()
    let days: Int
    let title: String
    let icon: String

    static let all: [StreakMilestone] = [
        StreakMilestone(days: 7, title: "Week Warrior", icon: "flame.fill"),
        StreakMilestone(days: 30, title: "Monthly Master", icon: "star.fill"),
        StreakMilestone(days: 100, title: "Century Club", icon: "crown.fill"),
        StreakMilestone(days: 365, title: "Year Legend", icon: "trophy.fill")
    ]
}
