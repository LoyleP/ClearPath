import Foundation

// MARK: - Money Lab Simulator
enum MoneyLabSimulator: String, CaseIterable, Identifiable, Codable {
    case paycheckBreakdown = "Paycheck Breakdown"
    case debtPayoff = "Debt Payoff"
    case compoundGrowth = "Compound Growth"
    case budgetAllocator = "Budget Allocator"
    case creditUtilization = "Credit Utilization"

    var id: String { rawValue }

    var description: String {
        switch self {
        case .paycheckBreakdown:
            return "Understand gross vs net, deductions"
        case .debtPayoff:
            return "Compare avalanche vs snowball strategies"
        case .compoundGrowth:
            return "Visualize investment growth over time"
        case .budgetAllocator:
            return "Apply 50/30/20 rule to your income"
        case .creditUtilization:
            return "See impact on credit score"
        }
    }

    var icon: String {
        switch self {
        case .paycheckBreakdown: return "dollarsign.square.fill"
        case .debtPayoff: return "arrow.down.forward.circle.fill"
        case .compoundGrowth: return "chart.line.uptrend.xyaxis.circle.fill"
        case .budgetAllocator: return "chart.pie.fill"
        case .creditUtilization: return "creditcard.circle.fill"
        }
    }
}

// MARK: - Paycheck Breakdown Input/Result
struct PaycheckBreakdownInput: Codable, Equatable {
    var grossSalary: Double
    var payFrequency: PayFrequency
    var filingStatus: FilingStatus
    var state: String
    var retirement401kPercent: Double
    var healthInsuranceMonthly: Double

    enum PayFrequency: String, CaseIterable, Codable {
        case weekly = "Weekly"
        case biweekly = "Bi-weekly"
        case semimonthly = "Semi-monthly"
        case monthly = "Monthly"

        var periodsPerYear: Int {
            switch self {
            case .weekly: return 52
            case .biweekly: return 26
            case .semimonthly: return 24
            case .monthly: return 12
            }
        }
    }

    enum FilingStatus: String, CaseIterable, Codable {
        case single = "Single"
        case marriedJointly = "Married Filing Jointly"
        case marriedSeparately = "Married Filing Separately"
        case headOfHousehold = "Head of Household"
    }
}

struct PaycheckBreakdownResult: Codable, Equatable {
    let grossPayPerPeriod: Double
    let federalTax: Double
    let socialSecurity: Double
    let medicare: Double
    let stateTax: Double
    let retirement401k: Double
    let healthInsurance: Double
    let netPay: Double

    var totalDeductions: Double {
        federalTax + socialSecurity + medicare + stateTax + retirement401k + healthInsurance
    }
}

// MARK: - Debt Payoff Input/Result
struct DebtPayoffInput: Codable, Equatable {
    var debts: [DebtItem]
    var monthlyPayment: Double
}

struct DebtItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var balance: Double
    var interestRate: Double // Annual percentage
    var minimumPayment: Double

    init(id: UUID = UUID(), name: String, balance: Double, interestRate: Double, minimumPayment: Double) {
        self.id = id
        self.name = name
        self.balance = balance
        self.interestRate = interestRate
        self.minimumPayment = minimumPayment
    }
}

struct DebtPayoffResult: Codable, Equatable {
    let avalancheMonths: Int
    let avalancheTotalInterest: Double
    let snowballMonths: Int
    let snowballTotalInterest: Double
    let interestSaved: Double
    let strategy: String
}

// MARK: - Compound Growth Input/Result
struct CompoundGrowthInput: Codable, Equatable {
    var initialAmount: Double
    var monthlyContribution: Double
    var annualReturn: Double // Percentage
    var years: Int
}

struct CompoundGrowthResult: Codable, Equatable {
    let totalContributed: Double
    let totalEarnings: Double
    let finalBalance: Double
    let yearByYearBalance: [Double]
}

// MARK: - Budget Allocator Input/Result
struct BudgetAllocatorInput: Codable, Equatable {
    var monthlyIncome: Double
}

struct BudgetAllocatorResult: Codable, Equatable {
    let needs: Double      // 50%
    let wants: Double      // 30%
    let savings: Double    // 20%

    var needsExamples: [String] {
        ["Rent/Mortgage", "Utilities", "Groceries", "Insurance", "Transportation"]
    }

    var wantsExamples: [String] {
        ["Dining out", "Entertainment", "Shopping", "Hobbies", "Subscriptions"]
    }

    var savingsExamples: [String] {
        ["Emergency fund", "Retirement", "Debt payoff", "Investments", "Future goals"]
    }
}

// MARK: - Credit Utilization Input/Result
struct CreditUtilizationInput: Codable, Equatable {
    var creditLimit: Double
    var currentBalance: Double
}

struct CreditUtilizationResult: Codable, Equatable {
    let utilizationPercent: Double
    let rating: CreditUtilizationRating
    let recommendation: String

    enum CreditUtilizationRating: String, Codable {
        case excellent = "Excellent"
        case good = "Good"
        case fair = "Fair"
        case poor = "Poor"
    }
}

// MARK: - Saved Scenario
struct SavedScenario: Identifiable, Codable, Equatable {
    let id: UUID
    let simulator: MoneyLabSimulator
    let name: String
    let createdAt: Date
    let inputData: Data // Encoded input
    let resultData: Data // Encoded result

    init(id: UUID = UUID(), simulator: MoneyLabSimulator, name: String, createdAt: Date = Date(), inputData: Data, resultData: Data) {
        self.id = id
        self.simulator = simulator
        self.name = name
        self.createdAt = createdAt
        self.inputData = inputData
        self.resultData = resultData
    }
}
