import SwiftUI

// MARK: - Lesson Complete View
struct LessonCompleteView: View {
    @Environment(AppStateController.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let lesson: Lesson
    let correctAnswers: Int
    let totalQuestions: Int

    @State private var showingMoneyLab = false

    private var xpEarned: Int {
        10 + (correctAnswers * 2)
    }

    private var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: CPSpacing.xxl) {
                // Success Animation
                ZStack {
                    Circle()
                        .fill(Color.cpSuccess.opacity(0.15))
                        .frame(width: 140, height: 140)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(Color.cpSuccess)
                }
                .padding(.top, CPSpacing.xxl)

                // Title
                Text("Lesson Complete!")
                    .font(.cpTitle)
                    .foregroundStyle(Color.cpLabel)

                // Stats Cards
                HStack(spacing: CPSpacing.md) {
                    StatCard(
                        value: "+\(xpEarned)",
                        label: "XP Earned",
                        icon: "star.fill",
                        color: .yellow
                    )

                    StatCard(
                        value: "\(Int(accuracy * 100))%",
                        label: "Accuracy",
                        icon: "target",
                        color: .blue
                    )

                    StatCard(
                        value: "+1",
                        label: "Streak",
                        icon: "flame.fill",
                        color: .orange
                    )
                }
                .padding(.horizontal, CPSpacing.md)

                // Sources Section
                SourcesSection(lesson: lesson)
                    .padding(.horizontal, CPSpacing.md)

                // Money Lab CTA
                MoneyLabCTA(action: { showingMoneyLab = true })
                    .padding(.horizontal, CPSpacing.md)

                Spacer(minLength: CPSpacing.xl)

                // Continue Button
                Button {
                    dismiss()
                } label: {
                    Text("Continue")
                }
                .cpPrimaryButton()
                .padding(.horizontal, CPSpacing.md)
                .padding(.bottom, CPSpacing.xl)
            }
        }
        .background(Color.cpBackground)
        .sheet(isPresented: $showingMoneyLab) {
            // Navigate to relevant simulator based on lesson
            SimulatorView(simulator: .paycheckBreakdown)
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: CPSpacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.cpHeadline)
                .foregroundStyle(Color.cpLabel)

            Text(label)
                .font(.cpCaption)
                .foregroundStyle(Color.cpSecondaryLabel)
        }
        .frame(maxWidth: .infinity)
        .padding(CPSpacing.md)
        .background(Color.cpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
    }
}

// MARK: - Sources Section
struct SourcesSection: View {
    let lesson: Lesson

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.sm) {
            Text("Sources")
                .font(.cpHeadline)
                .foregroundStyle(Color.cpLabel)

            VStack(alignment: .leading, spacing: CPSpacing.xs) {
                ForEach(lesson.sources) { source in
                    HStack(spacing: CPSpacing.xs) {
                        Image(systemName: "doc.text.fill")
                            .font(.caption)
                            .foregroundStyle(Color.cpTertiaryLabel)

                        Text(source.citation)
                            .font(.cpCaption)
                            .foregroundStyle(Color.cpSecondaryLabel)
                    }
                }

                if lesson.sources.isEmpty {
                    Text("Expert reviewed content")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }
            }

            // Reviewer
            HStack(spacing: CPSpacing.sm) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(Color.cpSuccess)

                Text("Reviewed by \(lesson.reviewerName), \(lesson.reviewerCredential)")
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpSecondaryLabel)
            }
        }
        .padding(CPSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
    }
}

// MARK: - Money Lab CTA
struct MoneyLabCTA: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CPSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: "flask.fill")
                        .foregroundStyle(Color.purple)
                }

                VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                    Text("Try it with your numbers")
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    Text("See how this applies to you")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.cpSecondaryLabel)
            }
            .padding(CPSpacing.md)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LessonCompleteView(
        lesson: Lesson.sampleLesson,
        correctAnswers: 6,
        totalQuestions: 8
    )
    .environment(AppStateController())
}
