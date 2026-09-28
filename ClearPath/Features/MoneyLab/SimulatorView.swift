import SwiftUI
import Charts

// MARK: - Simulator View
struct SimulatorView: View {
    @Environment(AppStateController.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let simulator: MoneyLabSimulator

    @State private var showingResult = false

    var body: some View {
        NavigationStack {
            Group {
                switch simulator {
                case .paycheckBreakdown:
                    PaycheckBreakdownSimulator(showingResult: $showingResult)
                case .debtPayoff:
                    DebtPayoffSimulator(showingResult: $showingResult)
                case .compoundGrowth:
                    CompoundGrowthSimulator(showingResult: $showingResult)
                case .budgetAllocator:
                    BudgetAllocatorSimulator(showingResult: $showingResult)
                case .creditUtilization:
                    CreditUtilizationSimulator(showingResult: $showingResult)
                }
            }
            .navigationTitle(simulator.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Privacy Banner
struct PrivacyBanner: View {
    var body: some View {
        HStack(spacing: CPSpacing.sm) {
            Image(systemName: "lock.shield.fill")
                .foregroundStyle(Color.cpSuccess)

            Text("Calculated on your device. Nothing sent to any server.")
                .font(.cpCaption)
                .foregroundStyle(Color.cpSecondaryLabel)
        }
        .padding(CPSpacing.sm)
        .frame(maxWidth: .infinity)
        .background(Color.cpSuccess.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.sm))
    }
}

// MARK: - Disclaimer Text
struct DisclaimerText: View {
    var body: some View {
        Text("Hypothetical. Assumptions shown. Not financial advice.")
            .font(.cpCaption)
            .foregroundStyle(Color.cpSecondaryLabel)
            .multilineTextAlignment(.center)
            .padding(.horizontal, CPSpacing.md)
    }
}

// MARK: - Currency Input Field
struct CurrencyInputField: View {
    let title: String
    @Binding var value: Double
    var placeholder: String = "0"

    @State private var textValue: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.xxs) {
            Text(title)
                .font(.cpCaption)
                .foregroundStyle(Color.cpSecondaryLabel)

            HStack {
                Text("$")
                    .foregroundStyle(Color.cpSecondaryLabel)

                TextField(placeholder, text: $textValue)
                    .keyboardType(.decimalPad)
                    .onChange(of: textValue) { _, newValue in
                        value = Double(newValue.replacingOccurrences(of: ",", with: "")) ?? 0
                    }
            }
            .padding(CPSpacing.sm)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.sm))
        }
        .onAppear {
            if value > 0 {
                textValue = String(format: "%.0f", value)
            }
        }
    }
}

// MARK: - Percentage Input Field
struct PercentageInputField: View {
    let title: String
    @Binding var value: Double
    var placeholder: String = "0"

    @State private var textValue: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.xxs) {
            Text(title)
                .font(.cpCaption)
                .foregroundStyle(Color.cpSecondaryLabel)

            HStack {
                TextField(placeholder, text: $textValue)
                    .keyboardType(.decimalPad)
                    .onChange(of: textValue) { _, newValue in
                        value = Double(newValue) ?? 0
                    }

                Text("%")
                    .foregroundStyle(Color.cpSecondaryLabel)
            }
            .padding(CPSpacing.sm)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.sm))
        }
        .onAppear {
            if value > 0 {
                textValue = String(format: "%.1f", value)
            }
        }
    }
}

// MARK: - Paycheck Breakdown Simulator
struct PaycheckBreakdownSimulator: View {
    @Environment(AppStateController.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @Binding var showingResult: Bool

    @State private var grossSalary: Double = 0
    @State private var payFrequency: PaycheckBreakdownInput.PayFrequency = .biweekly
    @State private var filingStatus: PaycheckBreakdownInput.FilingStatus = .single
    @State private var retirement401kPercent: Double = 6
    @State private var healthInsuranceMonthly: Double = 0

    @State private var result: PaycheckBreakdownResult?

    var body: some View {
        ScrollView {
            VStack(spacing: CPSpacing.lg) {
                if let result = result {
                    // Results View
                    PaycheckResultView(result: result, frequency: payFrequency)

                    Button("Run Again") {
                        self.result = nil
                    }
                    .cpSecondaryButton()

                    DisclaimerText()
                } else {
                    // Input View
                    PrivacyBanner()

                    VStack(spacing: CPSpacing.md) {
                        CurrencyInputField(title: "Annual Gross Salary", value: $grossSalary)

                        VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                            Text("Pay Frequency")
                                .font(.cpCaption)
                                .foregroundStyle(Color.cpSecondaryLabel)

                            Picker("Pay Frequency", selection: $payFrequency) {
                                ForEach(PaycheckBreakdownInput.PayFrequency.allCases, id: \.self) { freq in
                                    Text(freq.rawValue).tag(freq)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                            Text("Filing Status")
                                .font(.cpCaption)
                                .foregroundStyle(Color.cpSecondaryLabel)

                            Picker("Filing Status", selection: $filingStatus) {
                                ForEach(PaycheckBreakdownInput.FilingStatus.allCases, id: \.self) { status in
                                    Text(status.rawValue).tag(status)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(CPSpacing.sm)
                            .background(Color.cpSecondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.sm))
                        }

                        PercentageInputField(title: "401(k) Contribution", value: $retirement401kPercent)

                        CurrencyInputField(title: "Monthly Health Insurance", value: $healthInsuranceMonthly)
                    }

                    Button("Calculate") {
                        calculatePaycheck()
                    }
                    .cpPrimaryButton()
                    .disabled(grossSalary <= 0)
                }
            }
            .padding(CPSpacing.md)
        }
        .background(Color.cpBackground)
    }

    private func calculatePaycheck() {
        let grossPerPeriod = grossSalary / Double(payFrequency.periodsPerYear)

        // Simplified tax calculations (mock)
        let federalTax = grossPerPeriod * 0.22 // Simplified federal rate
        let socialSecurity = grossPerPeriod * 0.062
        let medicare = grossPerPeriod * 0.0145
        let stateTax = grossPerPeriod * 0.05 // Simplified state rate
        let retirement = grossPerPeriod * (retirement401kPercent / 100)
        let health = healthInsuranceMonthly / Double(payFrequency.periodsPerYear) * 12

        let netPay = grossPerPeriod - federalTax - socialSecurity - medicare - stateTax - retirement - health

        result = PaycheckBreakdownResult(
            grossPayPerPeriod: grossPerPeriod,
            federalTax: federalTax,
            socialSecurity: socialSecurity,
            medicare: medicare,
            stateTax: stateTax,
            retirement401k: retirement,
            healthInsurance: health,
            netPay: max(0, netPay)
        )

        appState.dataManager.recordMoneyLabRun()
    }
}

// MARK: - Paycheck Result View
struct PaycheckResultView: View {
    let result: PaycheckBreakdownResult
    let frequency: PaycheckBreakdownInput.PayFrequency

    var body: some View {
        VStack(spacing: CPSpacing.lg) {
            // Net Pay Hero
            VStack(spacing: CPSpacing.xxs) {
                Text("Your Take-Home Pay")
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpSecondaryLabel)

                Text(formatCurrency(result.netPay))
                    .font(.cpDisplayMedium)
                    .foregroundStyle(Color.cpSuccess)

                Text("per \(frequency.rawValue.lowercased()) paycheck")
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpSecondaryLabel)
            }
            .padding(CPSpacing.lg)
            .frame(maxWidth: .infinity)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))

            // Breakdown
            VStack(alignment: .leading, spacing: CPSpacing.sm) {
                Text("Paycheck Breakdown")
                    .font(.cpHeadline)
                    .foregroundStyle(Color.cpLabel)

                DeductionRow(title: "Gross Pay", amount: result.grossPayPerPeriod, isTotal: true)
                Divider()
                DeductionRow(title: "Federal Tax", amount: -result.federalTax)
                DeductionRow(title: "Social Security", amount: -result.socialSecurity)
                DeductionRow(title: "Medicare", amount: -result.medicare)
                DeductionRow(title: "State Tax", amount: -result.stateTax)
                DeductionRow(title: "401(k)", amount: -result.retirement401k)
                DeductionRow(title: "Health Insurance", amount: -result.healthInsurance)
                Divider()
                DeductionRow(title: "Net Pay", amount: result.netPay, isTotal: true, isPositive: true)
            }
            .padding(CPSpacing.md)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Deduction Row
struct DeductionRow: View {
    let title: String
    let amount: Double
    var isTotal: Bool = false
    var isPositive: Bool = false

    var body: some View {
        HStack {
            Text(title)
                .font(isTotal ? .cpBodyBold : .cpBody)
                .foregroundStyle(Color.cpLabel)

            Spacer()

            Text(formatCurrency(amount))
                .font(isTotal ? .cpBodyBold : .cpBody)
                .foregroundStyle(isPositive ? Color.cpSuccess : (amount < 0 ? Color.cpError : Color.cpLabel))
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        let sign = value < 0 ? "" : (value > 0 && !isPositive ? "+" : "")
        return sign + (formatter.string(from: NSNumber(value: abs(value))) ?? "$0")
    }
}

// MARK: - Compound Growth Simulator
struct CompoundGrowthSimulator: View {
    @Environment(AppStateController.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @Binding var showingResult: Bool

    @State private var initialAmount: Double = 0
    @State private var monthlyContribution: Double = 0
    @State private var annualReturn: Double = 7
    @State private var years: Double = 30

    @State private var result: CompoundGrowthResult?

    var body: some View {
        ScrollView {
            VStack(spacing: CPSpacing.lg) {
                if let result = result {
                    CompoundGrowthResultView(result: result, years: Int(years))

                    Button("Run Again") {
                        self.result = nil
                    }
                    .cpSecondaryButton()

                    DisclaimerText()
                } else {
                    PrivacyBanner()

                    VStack(spacing: CPSpacing.md) {
                        CurrencyInputField(title: "Starting Amount", value: $initialAmount)
                        CurrencyInputField(title: "Monthly Contribution", value: $monthlyContribution)
                        PercentageInputField(title: "Expected Annual Return", value: $annualReturn)

                        VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                            Text("Investment Period: \(Int(years)) years")
                                .font(.cpCaption)
                                .foregroundStyle(Color.cpSecondaryLabel)

                            Slider(value: $years, in: 5...50, step: 1)
                                .tint(Color.blue)
                        }
                    }

                    Button("Calculate Growth") {
                        calculateGrowth()
                    }
                    .cpPrimaryButton()
                }
            }
            .padding(CPSpacing.md)
        }
        .background(Color.cpBackground)
    }

    private func calculateGrowth() {
        let monthlyRate = annualReturn / 100 / 12
        let months = Int(years) * 12

        var balances: [Double] = []
        var balance = initialAmount

        for month in 0..<months {
            balance = balance * (1 + monthlyRate) + monthlyContribution
            if month % 12 == 11 {
                balances.append(balance)
            }
        }

        let totalContributed = initialAmount + (monthlyContribution * Double(months))

        result = CompoundGrowthResult(
            totalContributed: totalContributed,
            totalEarnings: balance - totalContributed,
            finalBalance: balance,
            yearByYearBalance: balances
        )

        appState.dataManager.recordMoneyLabRun()
    }
}

// MARK: - Compound Growth Result View
struct CompoundGrowthResultView: View {
    let result: CompoundGrowthResult
    let years: Int

    var body: some View {
        VStack(spacing: CPSpacing.lg) {
            // Final Balance Hero
            VStack(spacing: CPSpacing.xxs) {
                Text("Final Balance")
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpSecondaryLabel)

                Text(formatCurrency(result.finalBalance))
                    .font(.cpDisplayMedium)
                    .foregroundStyle(Color.cpSuccess)

                Text("after \(years) years")
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpSecondaryLabel)
            }
            .padding(CPSpacing.lg)
            .frame(maxWidth: .infinity)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))

            // Chart
            if !result.yearByYearBalance.isEmpty {
                Chart {
                    ForEach(Array(result.yearByYearBalance.enumerated()), id: \.offset) { index, balance in
                        LineMark(
                            x: .value("Year", index + 1),
                            y: .value("Balance", balance)
                        )
                        .foregroundStyle(Color.blue)

                        AreaMark(
                            x: .value("Year", index + 1),
                            y: .value("Balance", balance)
                        )
                        .foregroundStyle(Color.blue.opacity(0.1))
                    }
                }
                .frame(height: 200)
                .padding(CPSpacing.md)
                .background(Color.cpSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
            }

            // Breakdown
            HStack(spacing: CPSpacing.md) {
                BreakdownCard(
                    title: "Contributed",
                    value: formatCurrency(result.totalContributed),
                    color: .blue
                )

                BreakdownCard(
                    title: "Earnings",
                    value: formatCurrency(result.totalEarnings),
                    color: .cpSuccess
                )
            }
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Breakdown Card
struct BreakdownCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: CPSpacing.xxs) {
            Text(title)
                .font(.cpCaption)
                .foregroundStyle(Color.cpSecondaryLabel)

            Text(value)
                .font(.cpHeadline)
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(CPSpacing.md)
        .background(Color.cpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
    }
}

// MARK: - Budget Allocator Simulator
struct BudgetAllocatorSimulator: View {
    @Environment(AppStateController.self) private var appState
    @Binding var showingResult: Bool

    @State private var monthlyIncome: Double = 0
    @State private var result: BudgetAllocatorResult?

    var body: some View {
        ScrollView {
            VStack(spacing: CPSpacing.lg) {
                if let result = result {
                    BudgetAllocatorResultView(result: result)

                    Button("Run Again") {
                        self.result = nil
                    }
                    .cpSecondaryButton()

                    DisclaimerText()
                } else {
                    PrivacyBanner()

                    CurrencyInputField(title: "Monthly Take-Home Income", value: $monthlyIncome)

                    InfoBox(text: "We'll apply the 50/30/20 rule: 50% needs, 30% wants, 20% savings")

                    Button("Calculate Budget") {
                        calculateBudget()
                    }
                    .cpPrimaryButton()
                    .disabled(monthlyIncome <= 0)
                }
            }
            .padding(CPSpacing.md)
        }
        .background(Color.cpBackground)
    }

    private func calculateBudget() {
        result = BudgetAllocatorResult(
            needs: monthlyIncome * 0.5,
            wants: monthlyIncome * 0.3,
            savings: monthlyIncome * 0.2
        )

        appState.dataManager.recordMoneyLabRun()
    }
}

// MARK: - Budget Allocator Result View
struct BudgetAllocatorResultView: View {
    let result: BudgetAllocatorResult

    var body: some View {
        VStack(spacing: CPSpacing.lg) {
            // Pie Chart representation
            HStack(spacing: 0) {
                BudgetSegment(percentage: 50, label: "Needs", color: .blue)
                BudgetSegment(percentage: 30, label: "Wants", color: .purple)
                BudgetSegment(percentage: 20, label: "Savings", color: .cpSuccess)
            }
            .frame(height: 40)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.sm))

            // Detailed breakdown
            BudgetCategoryCard(
                title: "Needs (50%)",
                amount: result.needs,
                examples: result.needsExamples,
                color: .blue
            )

            BudgetCategoryCard(
                title: "Wants (30%)",
                amount: result.wants,
                examples: result.wantsExamples,
                color: .purple
            )

            BudgetCategoryCard(
                title: "Savings (20%)",
                amount: result.savings,
                examples: result.savingsExamples,
                color: .cpSuccess
            )
        }
    }
}

// MARK: - Budget Segment
struct BudgetSegment: View {
    let percentage: Int
    let label: String
    let color: Color

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(maxWidth: .infinity)
            .overlay(
                Text("\(percentage)%")
                    .font(.cpCaption)
                    .foregroundStyle(.white)
            )
    }
}

// MARK: - Budget Category Card
struct BudgetCategoryCard: View {
    let title: String
    let amount: Double
    let examples: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.sm) {
            HStack {
                Text(title)
                    .font(.cpHeadline)
                    .foregroundStyle(Color.cpLabel)

                Spacer()

                Text(formatCurrency(amount))
                    .font(.cpHeadline)
                    .foregroundStyle(color)
            }

            Text(examples.joined(separator: " • "))
                .font(.cpCaption)
                .foregroundStyle(Color.cpSecondaryLabel)
        }
        .padding(CPSpacing.md)
        .background(Color.cpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Credit Utilization Simulator
struct CreditUtilizationSimulator: View {
    @Environment(AppStateController.self) private var appState
    @Binding var showingResult: Bool

    @State private var creditLimit: Double = 0
    @State private var currentBalance: Double = 0
    @State private var result: CreditUtilizationResult?

    var body: some View {
        ScrollView {
            VStack(spacing: CPSpacing.lg) {
                if let result = result {
                    CreditUtilizationResultView(result: result, balance: currentBalance, limit: creditLimit)

                    Button("Run Again") {
                        self.result = nil
                    }
                    .cpSecondaryButton()

                    DisclaimerText()
                } else {
                    PrivacyBanner()

                    VStack(spacing: CPSpacing.md) {
                        CurrencyInputField(title: "Total Credit Limit", value: $creditLimit)
                        CurrencyInputField(title: "Current Balance", value: $currentBalance)
                    }

                    InfoBox(text: "Credit utilization is how much of your available credit you're using. Lower is generally better for your credit score.")

                    Button("Check Utilization") {
                        calculateUtilization()
                    }
                    .cpPrimaryButton()
                    .disabled(creditLimit <= 0)
                }
            }
            .padding(CPSpacing.md)
        }
        .background(Color.cpBackground)
    }

    private func calculateUtilization() {
        let utilization = (currentBalance / creditLimit) * 100

        let rating: CreditUtilizationResult.CreditUtilizationRating
        let recommendation: String

        switch utilization {
        case 0..<10:
            rating = .excellent
            recommendation = "Excellent! You're using very little of your available credit."
        case 10..<30:
            rating = .good
            recommendation = "Good! Your utilization is in a healthy range."
        case 30..<50:
            rating = .fair
            recommendation = "Consider paying down your balance to improve your credit score."
        default:
            rating = .poor
            recommendation = "High utilization can hurt your credit score. Try to pay down your balance."
        }

        result = CreditUtilizationResult(
            utilizationPercent: utilization,
            rating: rating,
            recommendation: recommendation
        )

        appState.dataManager.recordMoneyLabRun()
    }
}

// MARK: - Credit Utilization Result View
struct CreditUtilizationResultView: View {
    let result: CreditUtilizationResult
    let balance: Double
    let limit: Double

    var ratingColor: Color {
        switch result.rating {
        case .excellent: return .cpSuccess
        case .good: return .blue
        case .fair: return .cpWarning
        case .poor: return .cpError
        }
    }

    var body: some View {
        VStack(spacing: CPSpacing.lg) {
            // Utilization Gauge
            VStack(spacing: CPSpacing.sm) {
                ZStack {
                    Circle()
                        .stroke(Color.cpSecondaryLabel.opacity(0.2), lineWidth: 15)
                        .frame(width: 150, height: 150)

                    Circle()
                        .trim(from: 0, to: min(result.utilizationPercent / 100, 1))
                        .stroke(ratingColor, style: StrokeStyle(lineWidth: 15, lineCap: .round))
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: CPSpacing.xxs) {
                        Text("\(Int(result.utilizationPercent))%")
                            .font(.cpDisplayMedium)
                            .foregroundStyle(ratingColor)

                        Text("Utilization")
                            .font(.cpCaption)
                            .foregroundStyle(Color.cpSecondaryLabel)
                    }
                }

                Text(result.rating.rawValue)
                    .font(.cpHeadline)
                    .foregroundStyle(ratingColor)
            }
            .padding(CPSpacing.lg)
            .frame(maxWidth: .infinity)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))

            // Balance Bar
            VStack(alignment: .leading, spacing: CPSpacing.sm) {
                Text("Credit Usage")
                    .font(.cpHeadline)
                    .foregroundStyle(Color.cpLabel)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.cpSecondaryLabel.opacity(0.2))
                            .frame(height: 20)

                        Rectangle()
                            .fill(ratingColor)
                            .frame(width: geometry.size.width * min(result.utilizationPercent / 100, 1), height: 20)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .frame(height: 20)

                HStack {
                    Text(formatCurrency(balance))
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpLabel)

                    Spacer()

                    Text("of \(formatCurrency(limit))")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }
            }
            .padding(CPSpacing.md)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))

            // Recommendation
            HStack(alignment: .top, spacing: CPSpacing.md) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(Color.yellow)

                Text(result.recommendation)
                    .font(.cpBody)
                    .foregroundStyle(Color.cpSecondaryLabel)
            }
            .padding(CPSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.yellow.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Debt Payoff Simulator
struct DebtPayoffSimulator: View {
    @Environment(AppStateController.self) private var appState
    @Binding var showingResult: Bool

    @State private var debts: [DebtItem] = []
    @State private var monthlyPayment: Double = 0
    @State private var result: DebtPayoffResult?
    @State private var showingAddDebt = false

    var body: some View {
        ScrollView {
            VStack(spacing: CPSpacing.lg) {
                if let result = result {
                    DebtPayoffResultView(result: result)

                    Button("Run Again") {
                        self.result = nil
                    }
                    .cpSecondaryButton()

                    DisclaimerText()
                } else {
                    PrivacyBanner()

                    // Debts List
                    VStack(alignment: .leading, spacing: CPSpacing.sm) {
                        Text("Your Debts")
                            .font(.cpHeadline)
                            .foregroundStyle(Color.cpLabel)

                        if debts.isEmpty {
                            Text("Add your debts to compare payoff strategies")
                                .font(.cpBody)
                                .foregroundStyle(Color.cpSecondaryLabel)
                                .padding(CPSpacing.md)
                        } else {
                            ForEach(debts) { debt in
                                DebtItemRow(debt: debt) {
                                    debts.removeAll { $0.id == debt.id }
                                }
                            }
                        }

                        Button {
                            showingAddDebt = true
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Debt")
                            }
                        }
                        .cpSecondaryButton()
                    }

                    CurrencyInputField(title: "Extra Monthly Payment", value: $monthlyPayment)

                    InfoBox(text: "We'll compare Avalanche (highest interest first) vs Snowball (smallest balance first) strategies")

                    Button("Compare Strategies") {
                        calculateDebtPayoff()
                    }
                    .cpPrimaryButton()
                    .disabled(debts.isEmpty)
                }
            }
            .padding(CPSpacing.md)
        }
        .background(Color.cpBackground)
        .sheet(isPresented: $showingAddDebt) {
            AddDebtSheet { newDebt in
                debts.append(newDebt)
            }
        }
    }

    private func calculateDebtPayoff() {
        // Simplified calculation (mock)
        let totalDebt = debts.reduce(0) { $0 + $1.balance }
        let avgRate = debts.reduce(0) { $0 + $1.interestRate } / Double(debts.count)

        let avalancheMonths = Int(totalDebt / (monthlyPayment + 200)) // Simplified
        let snowballMonths = avalancheMonths + 2 // Snowball typically takes longer

        let avalancheInterest = totalDebt * (avgRate / 100) * Double(avalancheMonths) / 12
        let snowballInterest = avalancheInterest * 1.15

        result = DebtPayoffResult(
            avalancheMonths: avalancheMonths,
            avalancheTotalInterest: avalancheInterest,
            snowballMonths: snowballMonths,
            snowballTotalInterest: snowballInterest,
            interestSaved: snowballInterest - avalancheInterest,
            strategy: "Avalanche saves you money. Snowball gives quicker wins."
        )

        appState.dataManager.recordMoneyLabRun()
    }
}

// MARK: - Debt Item Row
struct DebtItemRow: View {
    let debt: DebtItem
    let onDelete: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                Text(debt.name)
                    .font(.cpBodyBold)
                    .foregroundStyle(Color.cpLabel)

                Text("\(formatCurrency(debt.balance)) at \(String(format: "%.1f", debt.interestRate))%")
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpSecondaryLabel)
            }

            Spacer()

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "trash")
                    .foregroundStyle(Color.cpError)
            }
        }
        .padding(CPSpacing.md)
        .background(Color.cpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Add Debt Sheet
struct AddDebtSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (DebtItem) -> Void

    @State private var name: String = ""
    @State private var balance: Double = 0
    @State private var interestRate: Double = 0
    @State private var minimumPayment: Double = 0

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name (e.g., Credit Card)", text: $name)
                }

                Section {
                    CurrencyInputField(title: "Balance", value: $balance)
                    PercentageInputField(title: "Interest Rate", value: $interestRate)
                    CurrencyInputField(title: "Minimum Payment", value: $minimumPayment)
                }
            }
            .navigationTitle("Add Debt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        let debt = DebtItem(
                            name: name,
                            balance: balance,
                            interestRate: interestRate,
                            minimumPayment: minimumPayment
                        )
                        onAdd(debt)
                        dismiss()
                    }
                    .disabled(name.isEmpty || balance <= 0)
                }
            }
        }
    }
}

// MARK: - Debt Payoff Result View
struct DebtPayoffResultView: View {
    let result: DebtPayoffResult

    var body: some View {
        VStack(spacing: CPSpacing.lg) {
            // Comparison
            HStack(spacing: CPSpacing.md) {
                StrategyCard(
                    title: "Avalanche",
                    subtitle: "Highest interest first",
                    months: result.avalancheMonths,
                    interest: result.avalancheTotalInterest,
                    isRecommended: true
                )

                StrategyCard(
                    title: "Snowball",
                    subtitle: "Smallest balance first",
                    months: result.snowballMonths,
                    interest: result.snowballTotalInterest,
                    isRecommended: false
                )
            }

            // Savings highlight
            HStack(spacing: CPSpacing.md) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.title)
                    .foregroundStyle(Color.cpSuccess)

                VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                    Text("Avalanche saves you")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)

                    Text(formatCurrency(result.interestSaved))
                        .font(.cpTitle2)
                        .foregroundStyle(Color.cpSuccess)
                }

                Spacer()
            }
            .padding(CPSpacing.md)
            .background(Color.cpSuccess.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))

            // Strategy explanation
            Text(result.strategy)
                .font(.cpBody)
                .foregroundStyle(Color.cpSecondaryLabel)
                .multilineTextAlignment(.center)
        }
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Strategy Card
struct StrategyCard: View {
    let title: String
    let subtitle: String
    let months: Int
    let interest: Double
    let isRecommended: Bool

    var body: some View {
        VStack(spacing: CPSpacing.sm) {
            if isRecommended {
                Text("Recommended")
                    .font(.cpCaption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, CPSpacing.xs)
                    .padding(.vertical, 2)
                    .background(Color.cpSuccess)
                    .clipShape(Capsule())
            }

            Text(title)
                .font(.cpHeadline)
                .foregroundStyle(Color.cpLabel)

            Text(subtitle)
                .font(.cpCaption)
                .foregroundStyle(Color.cpSecondaryLabel)

            Divider()

            VStack(spacing: CPSpacing.xxs) {
                Text("\(months) months")
                    .font(.cpBodyBold)
                    .foregroundStyle(Color.cpLabel)

                Text(formatCurrency(interest) + " interest")
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpSecondaryLabel)
            }
        }
        .padding(CPSpacing.md)
        .frame(maxWidth: .infinity)
        .background(isRecommended ? Color.cpSuccess.opacity(0.1) : Color.cpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: CPCornerRadius.md)
                .stroke(isRecommended ? Color.cpSuccess : Color.clear, lineWidth: 2)
        )
    }

    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

#Preview {
    SimulatorView(simulator: .compoundGrowth)
        .environment(AppStateController())
}
