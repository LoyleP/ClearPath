import Foundation

// MARK: - Money Score Model
struct MoneyScore: Codable, Equatable {
    var knowledge: Double      // Up to 60 points
    var behaviour: Double      // Up to 25 points
    var consistency: Double    // Up to 15 points
    var lastUpdated: Date
    var previousScore: Double?

    init(
        knowledge: Double = 0,
        behaviour: Double = 0,
        consistency: Double = 0,
        lastUpdated: Date = Date(),
        previousScore: Double? = nil
    ) {
        self.knowledge = knowledge
        self.behaviour = behaviour
        self.consistency = consistency
        self.lastUpdated = lastUpdated
        self.previousScore = previousScore
    }

    var totalScore: Double {
        knowledge + behaviour + consistency
    }

    var scoreInt: Int {
        Int(totalScore.rounded())
    }

    var weeklyDelta: Double {
        guard let previous = previousScore else { return 0 }
        return totalScore - previous
    }

    var weeklyDeltaFormatted: String {
        let delta = weeklyDelta
        if delta > 0 {
            return "+\(Int(delta.rounded()))"
        } else if delta < 0 {
            return "\(Int(delta.rounded()))"
        }
        return "0"
    }

    // Component percentages
    var knowledgePercentage: Double { knowledge / 60.0 }
    var behaviourPercentage: Double { behaviour / 25.0 }
    var consistencyPercentage: Double { consistency / 15.0 }
}

// MARK: - Money Score Calculator
struct MoneyScoreCalculator {
    static func calculateKnowledge(from progress: UserProgress) -> Double {
        let masteryLevels = progress.conceptMastery.values
        guard !masteryLevels.isEmpty else { return 0 }

        // Sum of (level * weight) / (maxLevel * weight * conceptCount)
        let totalPossible = Double(masteryLevels.count * 5) // Max level is 5
        let actualSum = masteryLevels.reduce(0.0) { $0 + Double($1.level) }

        return (actualSum / totalPossible) * 60.0
    }

    static func calculateBehaviour(from responses: BehaviourCheckIn, moneyLabRuns: Int) -> Double {
        // 8 questions worth up to 20 points
        let checkInScore = Double(responses.positiveResponses) / 8.0 * 20.0

        // 1 verified Money Lab run worth 5 points
        let moneyLabScore = min(Double(moneyLabRuns), 1.0) * 5.0

        return checkInScore + moneyLabScore
    }

    static func calculateConsistency(activeDaysPerWeek: [Int]) -> Double {
        // Average over last 8 weeks, max 5 days/week
        guard !activeDaysPerWeek.isEmpty else { return 0 }

        let cappedDays = activeDaysPerWeek.map { min($0, 5) }
        let average = Double(cappedDays.reduce(0, +)) / Double(cappedDays.count)
        let normalizedScore = average / 5.0

        return normalizedScore * 15.0
    }
}

// MARK: - Behaviour Check-In
struct BehaviourCheckIn: Codable, Equatable {
    var lastCheckInDate: Date?
    var responses: [BehaviourQuestion: Bool]

    var positiveResponses: Int {
        responses.filter { $0.value }.count
    }

    var isCheckInDue: Bool {
        guard let lastDate = lastCheckInDate else { return true }
        let daysSinceLastCheckIn = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
        return daysSinceLastCheckIn >= 30
    }
}

// MARK: - Behaviour Questions
enum BehaviourQuestion: String, CaseIterable, Codable {
    case hasBudget = "I have a written budget"
    case tracksSpending = "I track my spending regularly"
    case hasEmergencyFund = "I have an emergency fund"
    case paysFullBalance = "I pay my credit card in full each month"
    case contributing401k = "I contribute to retirement accounts"
    case hasInsurance = "I have adequate insurance coverage"
    case checksCredit = "I check my credit report annually"
    case savesRegularly = "I save a portion of each paycheck"

    var question: String { rawValue }
}
