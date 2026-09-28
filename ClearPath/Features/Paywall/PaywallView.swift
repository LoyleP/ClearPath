import SwiftUI

// MARK: - Paywall View
struct PaywallView: View {
    @Environment(AppStateController.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: SubscriptionPlan = .annual
    @State private var showingLifetime = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CPSpacing.xl) {
                    // Header
                    PaywallHeader()

                    // Features List
                    PaywallFeatures()

                    // Plan Selection
                    PlanSelector(selectedPlan: $selectedPlan)

                    // Lifetime Option
                    Button {
                        showingLifetime = true
                    } label: {
                        Text("Pay once? Lifetime $99 →")
                            .font(.cpCallout)
                            .foregroundStyle(Color.blue)
                    }

                    // Legal Text
                    Text("Renews automatically until cancelled. Cancel anytime in Settings.")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpTertiaryLabel)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, CPSpacing.md)

                    // CTA Buttons (Equal visual weight)
                    VStack(spacing: CPSpacing.md) {
                        Button {
                            handlePurchase()
                        } label: {
                            Text("Start Pro")
                        }
                        .cpPrimaryButton()

                        Button {
                            handleContinueFree()
                        } label: {
                            Text("Continue free")
                        }
                        .cpSecondaryButton()
                    }

                    // Footer Links
                    HStack(spacing: CPSpacing.lg) {
                        Button("Restore") {
                            handleRestore()
                        }
                        .font(.cpCaption)

                        Button("Terms") {
                            // Open terms
                        }
                        .font(.cpCaption)

                        Button("Privacy") {
                            // Open privacy
                        }
                        .font(.cpCaption)
                    }
                    .foregroundStyle(Color.cpSecondaryLabel)
                    .padding(.bottom, CPSpacing.xl)
                }
                .padding(.horizontal, CPSpacing.md)
                .padding(.top, CPSpacing.md)
            }
            .background(Color.cpBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        handleContinueFree()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color.cpSecondaryLabel)
                    }
                }
            }
            .sheet(isPresented: $showingLifetime) {
                LifetimeOfferSheet()
            }
        }
        .onAppear {
            appState.recordPaywallShown()
        }
    }

    private func handlePurchase() {
        // Mock purchase - in real app, use StoreKit
        appState.dataManager.activateProSubscription()
        dismiss()
    }

    private func handleContinueFree() {
        appState.recordPaywallDismissed()
        dismiss()
    }

    private func handleRestore() {
        // Mock restore - in real app, call AppStore.sync()
        // For MVP, just show a message
    }
}

// MARK: - Subscription Plan
enum SubscriptionPlan: String, CaseIterable, Identifiable {
    case monthly = "Monthly"
    case annual = "Annual"

    var id: String { rawValue }

    var price: String {
        switch self {
        case .monthly: return "$4.99"
        case .annual: return "$39.99"
        }
    }

    var period: String {
        switch self {
        case .monthly: return "/mo"
        case .annual: return "/yr"
        }
    }

    var savings: String? {
        switch self {
        case .monthly: return nil
        case .annual: return "Save 33%"
        }
    }
}

// MARK: - Paywall Header
struct PaywallHeader: View {
    var body: some View {
        VStack(spacing: CPSpacing.md) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(LinearGradient.cpPrimaryGradient)

            Text("Keep going")
                .font(.cpTitle)
                .foregroundStyle(Color.cpLabel)

            Text("ClearPath Pro")
                .font(.cpTitle2)
                .foregroundStyle(Color.blue)
        }
    }
}

// MARK: - Paywall Features
struct PaywallFeatures: View {
    private let features = [
        ("infinity", "Unlimited lessons"),
        ("flask.fill", "Full Money Lab access"),
        ("chart.bar.fill", "Complete score breakdown"),
        ("bookmark.fill", "Save scenarios")
    ]

    var body: some View {
        VStack(spacing: CPSpacing.sm) {
            ForEach(features, id: \.0) { icon, text in
                HStack(spacing: CPSpacing.md) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(Color.blue)
                        .frame(width: 30)

                    Text(text)
                        .font(.cpBody)
                        .foregroundStyle(Color.cpLabel)

                    Spacer()

                    Image(systemName: "checkmark")
                        .font(.caption)
                        .foregroundStyle(Color.cpSuccess)
                }
            }
        }
        .padding(CPSpacing.md)
        .background(Color.cpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
    }
}

// MARK: - Plan Selector
struct PlanSelector: View {
    @Binding var selectedPlan: SubscriptionPlan

    var body: some View {
        VStack(spacing: CPSpacing.sm) {
            ForEach(SubscriptionPlan.allCases) { plan in
                PlanOption(
                    plan: plan,
                    isSelected: selectedPlan == plan
                ) {
                    selectedPlan = plan
                }
            }
        }
    }
}

// MARK: - Plan Option
struct PlanOption: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                    HStack(spacing: CPSpacing.xs) {
                        Text(plan.rawValue)
                            .font(.cpHeadline)
                            .foregroundStyle(Color.cpLabel)

                        if let savings = plan.savings {
                            Text(savings)
                                .font(.cpCaption)
                                .foregroundStyle(.white)
                                .padding(.horizontal, CPSpacing.xs)
                                .padding(.vertical, 2)
                                .background(Color.cpSuccess)
                                .clipShape(Capsule())
                        }
                    }

                    Text("\(plan.price)\(plan.period)")
                        .font(.cpBody)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.blue : Color.cpSecondaryLabel)
            }
            .padding(CPSpacing.md)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: CPCornerRadius.md)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Lifetime Offer Sheet
struct LifetimeOfferSheet: View {
    @Environment(AppStateController.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: CPSpacing.xl) {
                Spacer()

                Image(systemName: "infinity.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(LinearGradient.cpPrimaryGradient)

                Text("Lifetime Access")
                    .font(.cpTitle)
                    .foregroundStyle(Color.cpLabel)

                Text("$99")
                    .font(.cpDisplayLarge)
                    .foregroundStyle(Color.cpLabel)

                Text("One-time payment. Forever access.")
                    .font(.cpBody)
                    .foregroundStyle(Color.cpSecondaryLabel)

                Spacer()

                VStack(spacing: CPSpacing.md) {
                    Button {
                        appState.dataManager.activateProSubscription()
                        dismiss()
                    } label: {
                        Text("Get Lifetime")
                    }
                    .cpPrimaryButton()

                    Button {
                        dismiss()
                    } label: {
                        Text("Maybe later")
                    }
                    .cpTextButton()
                }
                .padding(.bottom, CPSpacing.xxl)
            }
            .padding(.horizontal, CPSpacing.xl)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Reverse Trial End View (D8 Downgrade)
struct ReverseTrialEndView: View {
    @Environment(AppStateController.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: CPSpacing.xl) {
                Spacer()

                // Summary
                VStack(spacing: CPSpacing.md) {
                    Text("Here's what you built:")
                        .font(.cpTitle2)
                        .foregroundStyle(Color.cpLabel)

                    HStack(spacing: CPSpacing.xl) {
                        StatSummary(
                            value: "\(appState.dataManager.moneyScore.scoreInt)",
                            label: "Score"
                        )
                        StatSummary(
                            value: "\(appState.dataManager.streak.currentStreak)",
                            label: "Day Streak"
                        )
                        StatSummary(
                            value: "\(appState.dataManager.userProgress.completedLessonIDs.count)",
                            label: "Lessons"
                        )
                    }
                }
                .padding(CPSpacing.xl)
                .background(Color.cpSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.lg))

                // Reassurance
                VStack(spacing: CPSpacing.sm) {
                    Text("All of it stays.")
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    Text("Pro adds: unlimited lessons, Money Lab, score deep-dive.")
                        .font(.cpBody)
                        .foregroundStyle(Color.cpSecondaryLabel)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // CTAs
                VStack(spacing: CPSpacing.md) {
                    Button {
                        appState.dataManager.activateProSubscription()
                        dismiss()
                    } label: {
                        Text("Start Pro")
                    }
                    .cpPrimaryButton()

                    Button {
                        appState.dataManager.endReverseTrial()
                        dismiss()
                    } label: {
                        Text("Continue free")
                    }
                    .cpSecondaryButton()
                }
                .padding(.bottom, CPSpacing.xxl)
            }
            .padding(.horizontal, CPSpacing.xl)
            .navigationTitle("Your Trial Ended")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Stat Summary
struct StatSummary: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: CPSpacing.xxs) {
            Text(value)
                .font(.cpTitle2)
                .foregroundStyle(Color.cpLabel)
            Text(label)
                .font(.cpCaption)
                .foregroundStyle(Color.cpSecondaryLabel)
        }
    }
}

#Preview {
    PaywallView()
        .environment(AppStateController())
}
