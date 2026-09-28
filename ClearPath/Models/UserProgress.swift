import Foundation

// MARK: - User Progress
struct UserProgress: Codable, Equatable {
    var completedLessonIDs: Set<UUID>
    var conceptMastery: [UUID: ConceptMastery]
    var lessonsCompletedToday: Int
    var lastLessonDate: Date?
    var totalXP: Int
    var weeklyXP: Int

    init(
        completedLessonIDs: Set<UUID> = [],
        conceptMastery: [UUID: ConceptMastery] = [:],
        lessonsCompletedToday: Int = 0,
        lastLessonDate: Date? = nil,
        totalXP: Int = 0,
        weeklyXP: Int = 0
    ) {
        self.completedLessonIDs = completedLessonIDs
        self.conceptMastery = conceptMastery
        self.lessonsCompletedToday = lessonsCompletedToday
        self.lastLessonDate = lastLessonDate
        self.totalXP = totalXP
        self.weeklyXP = weeklyXP
    }

    var hasCompletedDailyLesson: Bool {
        guard let lastDate = lastLessonDate else { return false }
        return Calendar.current.isDateInToday(lastDate) && lessonsCompletedToday > 0
    }

    var canStartNewLesson: Bool {
        !hasCompletedDailyLesson
    }

    mutating func recordLessonCompletion(lessonID: UUID, xpEarned: Int) {
        completedLessonIDs.insert(lessonID)
        totalXP += xpEarned
        weeklyXP += xpEarned
        lessonsCompletedToday += 1
        lastLessonDate = Date()
    }
}

// MARK: - Concept Mastery
struct ConceptMastery: Codable, Equatable {
    let conceptID: UUID
    var level: Int // 0-5
    var lastReviewDate: Date
    var correctStreak: Int

    init(conceptID: UUID, level: Int = 0, lastReviewDate: Date = Date(), correctStreak: Int = 0) {
        self.conceptID = conceptID
        self.level = level
        self.lastReviewDate = lastReviewDate
        self.correctStreak = correctStreak
    }

    // Knowledge decay intervals (days)
    static let decayIntervals: [Int: Int] = [
        1: 3,   // Level 1: decays after 3 days
        2: 7,   // Level 2: decays after 7 days
        3: 21,  // Level 3: decays after 21 days
        4: 60,  // Level 4: decays after 60 days
        5: 180  // Level 5: decays after 180 days
    ]

    var isDue: Bool {
        guard let interval = Self.decayIntervals[level] else { return level == 0 }
        let dueDate = Calendar.current.date(byAdding: .day, value: interval, to: lastReviewDate) ?? lastReviewDate
        return Date() >= dueDate
    }

    var daysUntilDecay: Int {
        guard let interval = Self.decayIntervals[level] else { return 0 }
        let dueDate = Calendar.current.date(byAdding: .day, value: interval, to: lastReviewDate) ?? lastReviewDate
        return Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
    }

    mutating func recordCorrectAnswer() {
        correctStreak += 1
        if correctStreak >= 1 && level < 5 {
            level += 1
        }
        lastReviewDate = Date()
    }

    mutating func recordWrongAnswer() {
        correctStreak = 0
        // Don't decrease level on wrong answer, just reset streak
    }

    mutating func applyDecay() {
        if isDue && level > 0 {
            level -= 1
        }
    }
}
