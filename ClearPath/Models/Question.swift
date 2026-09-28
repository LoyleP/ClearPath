import Foundation

// MARK: - Question Model
struct Question: Identifiable, Codable, Equatable {
    let id: UUID
    let type: QuestionType
    let content: String
    let options: [AnswerOption]?
    let correctAnswerID: UUID?
    let correctOrder: [UUID]? // For sort/rank questions
    let explanation: String
    let sourceCitation: String?
    let conceptID: UUID // For tracking mastery

    init(
        id: UUID = UUID(),
        type: QuestionType,
        content: String,
        options: [AnswerOption]? = nil,
        correctAnswerID: UUID? = nil,
        correctOrder: [UUID]? = nil,
        explanation: String,
        sourceCitation: String? = nil,
        conceptID: UUID = UUID()
    ) {
        self.id = id
        self.type = type
        self.content = content
        self.options = options
        self.correctAnswerID = correctAnswerID
        self.correctOrder = correctOrder
        self.explanation = explanation
        self.sourceCitation = sourceCitation
        self.conceptID = conceptID
    }
}

// MARK: - Question Types (8 types as per user flow)
enum QuestionType: String, Codable, CaseIterable {
    case conceptCheck = "Concept Check"
    case scenarioDecision = "Scenario Decision"
    case numberEstimate = "Number Estimate"
    case sortRank = "Sort/Rank"
    case spotTheMistake = "Spot the Mistake"
    case documentRead = "Document Read"
    case miniSim = "Mini Simulation"
    case mythOrFact = "Myth or Fact"

    var icon: String {
        switch self {
        case .conceptCheck: return "checkmark.circle"
        case .scenarioDecision: return "arrow.triangle.branch"
        case .numberEstimate: return "number"
        case .sortRank: return "arrow.up.arrow.down"
        case .spotTheMistake: return "exclamationmark.triangle"
        case .documentRead: return "doc.text"
        case .miniSim: return "play.circle"
        case .mythOrFact: return "questionmark.circle"
        }
    }
}

// MARK: - Answer Option
struct AnswerOption: Identifiable, Codable, Equatable {
    let id: UUID
    let content: String
    let isCorrect: Bool

    init(id: UUID = UUID(), content: String, isCorrect: Bool = false) {
        self.id = id
        self.content = content
        self.isCorrect = isCorrect
    }
}

// MARK: - Sample Questions
extension Question {
    static let sampleQuestions: [Question] = [
        Question(
            type: .conceptCheck,
            content: "What is the difference between gross pay and net pay?",
            options: [
                AnswerOption(content: "Gross pay is what you earn before taxes; net pay is what you take home", isCorrect: true),
                AnswerOption(content: "They are the same thing"),
                AnswerOption(content: "Net pay is always higher than gross pay"),
                AnswerOption(content: "Gross pay only includes bonuses")
            ],
            correctAnswerID: nil,
            explanation: "Gross pay is your total earnings before any deductions. Net pay (take-home pay) is what remains after taxes, insurance, retirement contributions, and other deductions are subtracted.",
            sourceCitation: "IRS Publication 15"
        ),
        Question(
            type: .mythOrFact,
            content: "You should always accept a raise because it increases your paycheck.",
            options: [
                AnswerOption(content: "Myth", isCorrect: true),
                AnswerOption(content: "Fact", isCorrect: false)
            ],
            explanation: "While raises generally increase take-home pay, a small raise could push you into a higher tax bracket for part of your income, or affect eligibility for certain benefits. It's usually still beneficial, but not automatically so.",
            sourceCitation: "IRS Tax Brackets 2024"
        ),
        Question(
            type: .numberEstimate,
            content: "If your gross pay is $50,000/year, approximately what percentage typically goes to federal taxes, Social Security, and Medicare combined?",
            options: [
                AnswerOption(content: "5-10%"),
                AnswerOption(content: "15-25%", isCorrect: true),
                AnswerOption(content: "35-45%"),
                AnswerOption(content: "50%+")
            ],
            explanation: "For a $50,000 salary, you'd typically pay around 12% federal income tax, 6.2% Social Security, and 1.45% Medicare — roughly 20% total before state taxes.",
            sourceCitation: "IRS Tax Brackets 2024"
        )
    ]
}
