import Foundation

// MARK: - Learning Track
struct Track: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let icon: String
    let lessons: [Lesson]
    let importanceWeight: Int // 1-3 for scoring

    var totalLessons: Int { lessons.count }

    func completedLessons(for progress: UserProgress) -> Int {
        lessons.filter { progress.completedLessonIDs.contains($0.id) }.count
    }

    func progressPercentage(for progress: UserProgress) -> Double {
        guard totalLessons > 0 else { return 0 }
        return Double(completedLessons(for: progress)) / Double(totalLessons)
    }
}

// MARK: - All Available Tracks
extension Track {
    static let allTracks: [Track] = [
        Track(
            id: UUID(),
            name: "Money Basics",
            description: "Foundation of personal finance",
            icon: "dollarsign.circle.fill",
            lessons: Lesson.moneyBasicsLessons,
            importanceWeight: 3
        ),
        Track(
            id: UUID(),
            name: "Banking & Credit",
            description: "Managing accounts and building credit",
            icon: "building.columns.fill",
            lessons: Lesson.bankingCreditLessons,
            importanceWeight: 3
        ),
        Track(
            id: UUID(),
            name: "Debt",
            description: "Understanding and managing debt",
            icon: "arrow.down.circle.fill",
            lessons: Lesson.debtLessons,
            importanceWeight: 2
        ),
        Track(
            id: UUID(),
            name: "Taxes",
            description: "Tax basics and strategies",
            icon: "doc.text.fill",
            lessons: Lesson.taxesLessons,
            importanceWeight: 2
        ),
        Track(
            id: UUID(),
            name: "Insurance",
            description: "Protecting yourself and assets",
            icon: "shield.fill",
            lessons: Lesson.insuranceLessons,
            importanceWeight: 1
        ),
        Track(
            id: UUID(),
            name: "Investing",
            description: "Growing your wealth",
            icon: "chart.line.uptrend.xyaxis",
            lessons: Lesson.investingLessons,
            importanceWeight: 2
        ),
        Track(
            id: UUID(),
            name: "Retirement",
            description: "Planning for the future",
            icon: "house.fill",
            lessons: Lesson.retirementLessons,
            importanceWeight: 2
        ),
        Track(
            id: UUID(),
            name: "Big Decisions",
            description: "Major financial choices",
            icon: "star.fill",
            lessons: Lesson.bigDecisionsLessons,
            importanceWeight: 1
        )
    ]
}
