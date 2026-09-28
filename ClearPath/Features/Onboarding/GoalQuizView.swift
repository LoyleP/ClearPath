import SwiftUI

// MARK: - Goal Quiz View
struct GoalQuizView: View {
    @Environment(AppStateController.self) private var appState
    @State private var selectedGoal: FinancialGoal?

    var body: some View {
        VStack(spacing: CPSpacing.xl) {
            // Header
            VStack(spacing: CPSpacing.sm) {
                Text("What's your priority?")
                    .font(.cpTitle)
                    .foregroundStyle(Color.cpLabel)

                Text("We'll personalize your learning path. You can always explore other topics.")
                    .font(.cpBody)
                    .foregroundStyle(Color.cpSecondaryLabel)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, CPSpacing.md)
            }
            .padding(.top, CPSpacing.xxl)

            // Goal Options
            ScrollView {
                VStack(spacing: CPSpacing.sm) {
                    ForEach(FinancialGoal.allCases) { goal in
                        GoalOptionButton(
                            goal: goal,
                            isSelected: selectedGoal == goal
                        ) {
                            withAnimation {
                                selectedGoal = goal
                            }
                        }
                    }
                }
                .padding(.horizontal, CPSpacing.md)
            }

            // Info Box
            InfoBox(text: "Your choice only sets the track order. All content is always available.")
                .padding(.horizontal, CPSpacing.md)

            // Continue Button
            Button {
                if let goal = selectedGoal {
                    appState.dataManager.updateUserGoal(goal)
                }
                appState.completeOnboarding()
            } label: {
                Text(selectedGoal != nil ? "Let's go!" : "Skip for now")
            }
            .cpPrimaryButton()
            .padding(.horizontal, CPSpacing.xl)
            .padding(.bottom, CPSpacing.xl)
        }
        .background(Color.cpBackground)
    }
}

// MARK: - Goal Option Button
struct GoalOptionButton: View {
    let goal: FinancialGoal
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CPSpacing.md) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: CPCornerRadius.sm)
                        .fill(isSelected ? Color.blue.opacity(0.2) : Color.cpSecondaryBackground)
                        .frame(width: 44, height: 44)

                    Image(systemName: goal.icon)
                        .font(.title3)
                        .foregroundStyle(isSelected ? Color.blue : Color.cpSecondaryLabel)
                }

                // Content
                VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                    Text(goal.rawValue)
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    Text(goal.description)
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }

                Spacer()

                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.blue)
                }
            }
            .padding(CPSpacing.md)
            .background(isSelected ? Color.blue.opacity(0.05) : Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: CPCornerRadius.md)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Info Box
struct InfoBox: View {
    let text: String

    var body: some View {
        HStack(spacing: CPSpacing.sm) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Color.blue)

            Text(text)
                .font(.cpCaption)
                .foregroundStyle(Color.cpSecondaryLabel)
        }
        .padding(CPSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.sm))
    }
}

#Preview {
    GoalQuizView()
        .environment(AppStateController())
}
