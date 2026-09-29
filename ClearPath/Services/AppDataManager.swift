import Foundation
import Observation

// MARK: - App Data Manager
// Central manager for all app data - persistence, user state, and business logic

@Observable
@MainActor
final class AppDataManager {
    // MARK: - Published State
    private(set) var currentUser: User?
    private(set) var userProgress: UserProgress
    private(set) var streak: Streak
    private(set) var moneyScore: MoneyScore
    private(set) var behaviourCheckIn: BehaviourCheckIn

    // MARK: - Content
    let tracks: [Track] = Track.allTracks

    // MARK: - Money Lab
    private(set) var moneyLabRunsThisMonth: Int = 0
    private(set) var dailyMoneyLabRunUsed: Bool = false
    private(set) var savedScenarios: [SavedScenario] = []

    // MARK: - Social (Mock Data)
    private(set) var friends: [Friend] = []
    private(set) var currentLeague: League?

    // MARK: - Computed Properties
    var hasProAccess: Bool {
        currentUser?.hasProAccess ?? false
    }

    var canStartNewLesson: Bool {
        hasProAccess || userProgress.canStartNewLesson
    }

    var fadingConcepts: [UUID] {
        userProgress.conceptMastery.values
            .filter { $0.isDue }
            .map { $0.conceptID }
    }

    var nextLesson: Lesson? {
        // Find first incomplete lesson based on user's preferred track order
        let preferredGoal = currentUser?.preferredGoal
        let orderedTracks = orderedTracks(for: preferredGoal)

        for track in orderedTracks {
            if let lesson = track.lessons.first(where: { !userProgress.completedLessonIDs.contains($0.id) }) {
                return lesson
            }
        }
        return nil
    }

    // MARK: - Initialization
    init() {
        self.userProgress = UserProgress()
        self.streak = Streak()
        self.moneyScore = MoneyScore()
        self.behaviourCheckIn = BehaviourCheckIn(responses: [:])

        // Load mock data for demo
        loadMockData()
    }

    // MARK: - Track Ordering
    func orderedTracks(for preferredGoal: FinancialGoal?) -> [Track] {
        guard let goal = preferredGoal else { return tracks }

        // Map goal to track name
        let goalTrackName: String
        switch goal {
        case .budgeting: goalTrackName = "Money Basics"
        case .credit: goalTrackName = "Banking & Credit"
        case .debt: goalTrackName = "Debt"
        case .taxes: goalTrackName = "Taxes"
        case .investing: goalTrackName = "Investing"
        case .retirement: goalTrackName = "Retirement"
        }

        // Reorder with preferred track first
        var ordered = tracks
        if let index = ordered.firstIndex(where: { $0.name == goalTrackName }) {
            let preferred = ordered.remove(at: index)
            ordered.insert(preferred, at: 0)
        }
        return ordered
    }

    // MARK: - User Actions
    func createUser(displayName: String, email: String?, provider: AuthProvider, preferredGoal: FinancialGoal?) {
        currentUser = User(
            displayName: displayName,
            email: email,
            hasCompletedOnboarding: true,
            preferredGoal: preferredGoal
        )
        saveData()
    }

    func updateUserGoal(_ goal: FinancialGoal) {
        currentUser?.preferredGoal = goal
        saveData()
    }

    func setReminderTime(_ time: Date) {
        currentUser?.reminderTime = time
        saveData()
    }

    func enablePushNotifications(_ enabled: Bool) {
        currentUser?.pushNotificationsEnabled = enabled
        saveData()
    }

    // MARK: - Lesson Actions
    func completeLesson(_ lesson: Lesson, correctAnswers: Int, totalQuestions: Int) {
        let xpEarned = calculateXP(correctAnswers: correctAnswers, totalQuestions: totalQuestions)
        userProgress.recordLessonCompletion(lessonID: lesson.id, xpEarned: xpEarned)

        // Record activity for streak
        streak.recordActivity()

        // Update money score
        updateMoneyScore()

        saveData()
    }

    func recordQuestionAnswer(conceptID: UUID, isCorrect: Bool) {
        var mastery = userProgress.conceptMastery[conceptID] ?? ConceptMastery(conceptID: conceptID)

        if isCorrect {
            mastery.recordCorrectAnswer()
        } else {
            mastery.recordWrongAnswer()
        }

        userProgress.conceptMastery[conceptID] = mastery
    }

    private func calculateXP(correctAnswers: Int, totalQuestions: Int) -> Int {
        let baseXP = 10
        let bonusXP = correctAnswers * 2
        return baseXP + bonusXP
    }

    // MARK: - Streak Actions
    func checkStreakStatus() {
        // Check if we need to consume a shield or repair
        if !streak.hasActivityToday {
            // Check if yesterday was missed
            let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            let yesterdayStart = Calendar.current.startOfDay(for: yesterday)

            if streak.activityCalendar[yesterdayStart] == nil {
                // Yesterday was missed
                if !streak.consumeShield() {
                    // No shield available
                    if streak.canRepairStreak {
                        // Repair available, but don't auto-use
                    } else {
                        // Reset streak
                        streak.resetStreak()
                    }
                }
            }
        }
        saveData()
    }

    func repairStreak() -> Bool {
        let success = streak.repairYesterday()
        if success {
            saveData()
        }
        return success
    }

    func markMilestoneCelebrated(_ days: Int) {
        streak.celebratedMilestones.insert(days)
        saveData()
    }

    // MARK: - Money Score
    func updateMoneyScore() {
        let previousScore = moneyScore.totalScore

        moneyScore.knowledge = MoneyScoreCalculator.calculateKnowledge(from: userProgress)
        moneyScore.behaviour = MoneyScoreCalculator.calculateBehaviour(from: behaviourCheckIn, moneyLabRuns: moneyLabRunsThisMonth)

        // Calculate consistency (mock: use streak data)
        let activeDays = min(streak.currentStreak, 40) // Cap at 8 weeks * 5 days
        let weeklyAverage = Double(activeDays) / 8.0
        moneyScore.consistency = min(weeklyAverage / 5.0, 1.0) * 15.0

        moneyScore.previousScore = previousScore
        moneyScore.lastUpdated = Date()

        saveData()
    }

    func completeBehaviourCheckIn(responses: [BehaviourQuestion: Bool]) {
        behaviourCheckIn.responses = responses
        behaviourCheckIn.lastCheckInDate = Date()
        updateMoneyScore()
    }

    // MARK: - Money Lab
    func recordMoneyLabRun() {
        moneyLabRunsThisMonth += 1
        dailyMoneyLabRunUsed = true
        updateMoneyScore()
    }

    func canRunMoneyLab() -> Bool {
        hasProAccess || !dailyMoneyLabRunUsed
    }

    func saveScenario(_ scenario: SavedScenario) {
        savedScenarios.append(scenario)
        saveData()
    }

    // MARK: - Subscription
    func startReverseTrial() {
        currentUser?.reverseTrialStartDate = Date()
        currentUser?.reverseTrialEnded = false
        saveData()
    }

    func endReverseTrial() {
        currentUser?.reverseTrialEnded = true
        saveData()
    }

    func activateProSubscription() {
        currentUser?.isPro = true
        currentUser?.proExpirationDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        saveData()
    }

    // MARK: - Persistence (Mock)
    private func saveData() {
        // In a real app, this would persist to UserDefaults, CoreData, or a server
        // For MVP, data is kept in memory
    }

    private func loadMockData() {
        // Create mock friends with all properties
        friends = [
            Friend(userID: UUID(), displayName: "Alex", currentStreak: 12, totalScore: 72, badgeCount: 5),
            Friend(userID: UUID(), displayName: "Jordan", currentStreak: 5, totalScore: 45, badgeCount: 2),
            Friend(userID: UUID(), displayName: "Taylor", currentStreak: 23, totalScore: 88, badgeCount: 8),
            Friend(userID: UUID(), displayName: "Sam", currentStreak: 3, totalScore: 31, badgeCount: 1)
        ]

        // Create mock league with current user
        let currentUserID = UUID()
        var mockMembers = (1...29).map { i in
            LeagueMember(
                userID: UUID(),
                displayName: "User \(i)",
                weeklyXP: Int.random(in: 50...500)
            )
        }
        // Add current user
        mockMembers.append(LeagueMember(
            userID: currentUserID,
            displayName: "You",
            weeklyXP: 150
        ))

        currentLeague = League(
            id: UUID(),
            tier: .bronze,
            members: mockMembers,
            weekStartDate: Date(),
            weekEndDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            currentUserID: currentUserID
        )
    }

    // MARK: - Reset for Testing
    func resetAllData() {
        currentUser = nil
        userProgress = UserProgress()
        streak = Streak()
        moneyScore = MoneyScore()
        behaviourCheckIn = BehaviourCheckIn(responses: [:])
        moneyLabRunsThisMonth = 0
        dailyMoneyLabRunUsed = false
        savedScenarios = []
    }

    // MARK: - Debug Helpers
    #if DEBUG
    /// Set the current streak and backfill activity calendar entries (DEBUG only)
    func debugSetStreak(currentStreak: Int, activityDates: [Date] = []) {
        streak.currentStreak = currentStreak
        for date in activityDates {
            streak.activityCalendar[Calendar.current.startOfDay(for: date)] = .completed
        }
        saveData()
    }

    /// Insert or overwrite a concept's mastery record (DEBUG only)
    func debugSetConceptMastery(_ mastery: ConceptMastery) {
        userProgress.conceptMastery[mastery.conceptID] = mastery
    }
    #endif
}
