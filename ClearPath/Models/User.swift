import Foundation

// MARK: - User Model
struct User: Identifiable, Codable, Equatable {
    let id: UUID
    var displayName: String
    var email: String?
    var avatarURL: URL?
    var createdAt: Date
    var isPro: Bool
    var proExpirationDate: Date?
    var hasCompletedOnboarding: Bool
    var preferredGoal: FinancialGoal?
    var reminderTime: Date?
    var pushNotificationsEnabled: Bool

    // Reverse trial
    var reverseTrialStartDate: Date?
    var reverseTrialEnded: Bool

    init(
        id: UUID = UUID(),
        displayName: String,
        email: String? = nil,
        avatarURL: URL? = nil,
        createdAt: Date = Date(),
        isPro: Bool = false,
        proExpirationDate: Date? = nil,
        hasCompletedOnboarding: Bool = false,
        preferredGoal: FinancialGoal? = nil,
        reminderTime: Date? = nil,
        pushNotificationsEnabled: Bool = false,
        reverseTrialStartDate: Date? = nil,
        reverseTrialEnded: Bool = false
    ) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.avatarURL = avatarURL
        self.createdAt = createdAt
        self.isPro = isPro
        self.proExpirationDate = proExpirationDate
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.preferredGoal = preferredGoal
        self.reminderTime = reminderTime
        self.pushNotificationsEnabled = pushNotificationsEnabled
        self.reverseTrialStartDate = reverseTrialStartDate
        self.reverseTrialEnded = reverseTrialEnded
    }

    var isInReverseTrial: Bool {
        guard let startDate = reverseTrialStartDate, !reverseTrialEnded else {
            return false
        }
        let trialEndDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate) ?? startDate
        return Date() < trialEndDate
    }

    var hasProAccess: Bool {
        isPro || isInReverseTrial
    }
}

// MARK: - Financial Goal
enum FinancialGoal: String, CaseIterable, Codable, Identifiable {
    case budgeting = "Budgeting"
    case credit = "Credit"
    case debt = "Debt"
    case taxes = "Taxes"
    case investing = "Investing"
    case retirement = "Retirement"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .budgeting: return "chart.pie.fill"
        case .credit: return "creditcard.fill"
        case .debt: return "arrow.down.circle.fill"
        case .taxes: return "doc.text.fill"
        case .investing: return "chart.line.uptrend.xyaxis"
        case .retirement: return "house.fill"
        }
    }

    var description: String {
        switch self {
        case .budgeting: return "Learn to track and manage your money"
        case .credit: return "Build and maintain good credit"
        case .debt: return "Strategies to pay off what you owe"
        case .taxes: return "Understand your taxes and deductions"
        case .investing: return "Grow your money over time"
        case .retirement: return "Plan for your future"
        }
    }
}

// MARK: - Auth Provider
enum AuthProvider: String, Codable {
    case apple
    case google
    case email
}
