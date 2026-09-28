import Foundation

// MARK: - Lesson Model
struct Lesson: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let description: String
    let trackID: UUID
    let questions: [Question]
    let estimatedMinutes: Int
    let sources: [ContentSource]
    let reviewerName: String
    let reviewerCredential: String

    var totalQuestions: Int { questions.count }
}

// MARK: - Content Source
struct ContentSource: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let url: URL?
    let citation: String
}

// MARK: - Sample Lessons
extension Lesson {
    static let sampleLesson = Lesson(
        id: UUID(),
        title: "Your First Paycheck",
        description: "Understanding gross vs net pay",
        trackID: UUID(),
        questions: Question.sampleQuestions,
        estimatedMinutes: 3,
        sources: [
            ContentSource(
                id: UUID(),
                name: "IRS Publication 15",
                url: URL(string: "https://www.irs.gov/pub15"),
                citation: "IRS Publication 15, 2024"
            )
        ],
        reviewerName: "Sarah Chen",
        reviewerCredential: "CFP®"
    )

    // Track-specific lesson arrays (simplified for MVP)
    static let moneyBasicsLessons: [Lesson] = [
        Lesson(id: UUID(), title: "Your First Paycheck", description: "Understanding gross vs net pay", trackID: UUID(), questions: Question.sampleQuestions, estimatedMinutes: 3, sources: [], reviewerName: "Sarah Chen", reviewerCredential: "CFP®"),
        Lesson(id: UUID(), title: "Budgeting 101", description: "The 50/30/20 rule", trackID: UUID(), questions: Question.sampleQuestions, estimatedMinutes: 3, sources: [], reviewerName: "Sarah Chen", reviewerCredential: "CFP®"),
        Lesson(id: UUID(), title: "Emergency Fund", description: "Why you need 3-6 months saved", trackID: UUID(), questions: Question.sampleQuestions, estimatedMinutes: 3, sources: [], reviewerName: "Sarah Chen", reviewerCredential: "CFP®"),
    ]

    static let bankingCreditLessons: [Lesson] = [
        Lesson(id: UUID(), title: "Checking vs Savings", description: "Different accounts for different needs", trackID: UUID(), questions: Question.sampleQuestions, estimatedMinutes: 3, sources: [], reviewerName: "Michael Torres", reviewerCredential: "CFA"),
        Lesson(id: UUID(), title: "Credit Score Basics", description: "What makes up your score", trackID: UUID(), questions: Question.sampleQuestions, estimatedMinutes: 3, sources: [], reviewerName: "Michael Torres", reviewerCredential: "CFA"),
    ]

    static let debtLessons: [Lesson] = [
        Lesson(id: UUID(), title: "Good Debt vs Bad Debt", description: "Not all debt is created equal", trackID: UUID(), questions: Question.sampleQuestions, estimatedMinutes: 3, sources: [], reviewerName: "Lisa Park", reviewerCredential: "CFP®"),
        Lesson(id: UUID(), title: "Avalanche vs Snowball", description: "Two strategies to pay off debt", trackID: UUID(), questions: Question.sampleQuestions, estimatedMinutes: 3, sources: [], reviewerName: "Lisa Park", reviewerCredential: "CFP®"),
    ]

    static let taxesLessons: [Lesson] = [
        Lesson(id: UUID(), title: "W-2 Explained", description: "Reading your tax forms", trackID: UUID(), questions: Question.sampleQuestions, estimatedMinutes: 3, sources: [], reviewerName: "James Kim", reviewerCredential: "CPA"),
    ]

    static let insuranceLessons: [Lesson] = [
        Lesson(id: UUID(), title: "Health Insurance 101", description: "HMO, PPO, and deductibles", trackID: UUID(), questions: Question.sampleQuestions, estimatedMinutes: 3, sources: [], reviewerName: "Amanda Brown", reviewerCredential: "CLU"),
    ]

    static let investingLessons: [Lesson] = [
        Lesson(id: UUID(), title: "Compound Interest", description: "The 8th wonder of the world", trackID: UUID(), questions: Question.sampleQuestions, estimatedMinutes: 3, sources: [], reviewerName: "David Lee", reviewerCredential: "CFA"),
        Lesson(id: UUID(), title: "Stocks vs Bonds", description: "Understanding asset classes", trackID: UUID(), questions: Question.sampleQuestions, estimatedMinutes: 3, sources: [], reviewerName: "David Lee", reviewerCredential: "CFA"),
    ]

    static let retirementLessons: [Lesson] = [
        Lesson(id: UUID(), title: "401(k) Basics", description: "Free money from your employer", trackID: UUID(), questions: Question.sampleQuestions, estimatedMinutes: 3, sources: [], reviewerName: "Rachel Green", reviewerCredential: "CFP®"),
    ]

    static let bigDecisionsLessons: [Lesson] = [
        Lesson(id: UUID(), title: "Rent vs Buy", description: "When homeownership makes sense", trackID: UUID(), questions: Question.sampleQuestions, estimatedMinutes: 3, sources: [], reviewerName: "Tom Wilson", reviewerCredential: "CFP®"),
    ]
}
