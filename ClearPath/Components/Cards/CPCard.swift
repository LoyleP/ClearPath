import SwiftUI

// MARK: - ClearPath Card Component
struct CPCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(CPSpacing.md)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.lg))
    }
}

// MARK: - Tappable Card
struct CPTappableCard<Content: View>: View {
    let action: () -> Void
    let content: Content

    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }

    var body: some View {
        Button(action: action) {
            content
                .padding(CPSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cpSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.lg))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Streak Card
struct StreakCard: View {
    let currentStreak: Int
    let bestStreak: Int
    let action: () -> Void

    var body: some View {
        CPTappableCard(action: action) {
            HStack(spacing: CPSpacing.md) {
                // Streak Icon
                ZStack {
                    Circle()
                        .fill(LinearGradient.cpStreakGradient)
                        .frame(width: 50, height: 50)

                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }

                VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                    Text("\(currentStreak) day streak")
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    Text("Best: \(bestStreak) days")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpTertiaryLabel)
            }
        }
    }
}

// MARK: - Money Score Card
struct MoneyScoreCard: View {
    let score: Int
    let delta: String
    let action: () -> Void

    var body: some View {
        CPTappableCard(action: action) {
            HStack(spacing: CPSpacing.md) {
                // Score Circle
                ZStack {
                    Circle()
                        .stroke(Color.cpSecondaryLabel.opacity(0.2), lineWidth: 6)
                        .frame(width: 60, height: 60)

                    Circle()
                        .trim(from: 0, to: CGFloat(score) / 100)
                        .stroke(
                            LinearGradient.cpPrimaryGradient,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))

                    Text("\(score)")
                        .font(.cpStreakNumber)
                        .foregroundStyle(Color.cpLabel)
                }

                VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                    Text("Money Score")
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    HStack(spacing: CPSpacing.xxs) {
                        Text(delta)
                            .font(.cpCalloutBold)
                            .foregroundStyle(delta.hasPrefix("+") ? Color.cpSuccess : (delta.hasPrefix("-") ? Color.cpError : Color.cpSecondaryLabel))

                        Text("this week")
                            .font(.cpCaption)
                            .foregroundStyle(Color.cpSecondaryLabel)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpTertiaryLabel)
            }
        }
    }
}

// MARK: - Lesson Card
struct LessonCard: View {
    let title: String
    let subtitle: String
    let estimatedMinutes: Int
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        CPTappableCard(action: action) {
            HStack(spacing: CPSpacing.md) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: CPCornerRadius.sm)
                        .fill(isCompleted ? Color.cpSuccess.opacity(0.2) : Color.blue.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "book.fill")
                        .font(.title2)
                        .foregroundStyle(isCompleted ? Color.cpSuccess : Color.blue)
                }

                VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                    Text(title)
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    HStack(spacing: CPSpacing.xs) {
                        Text(subtitle)
                            .font(.cpCaption)
                            .foregroundStyle(Color.cpSecondaryLabel)

                        Text("•")
                            .foregroundStyle(Color.cpTertiaryLabel)

                        Text("\(estimatedMinutes) min")
                            .font(.cpCaption)
                            .foregroundStyle(Color.cpSecondaryLabel)
                    }
                }

                Spacer()

                if !isCompleted {
                    Text("Start")
                        .font(.cpCalloutBold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, CPSpacing.sm)
                        .padding(.vertical, CPSpacing.xs)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

// MARK: - Review Card
struct ReviewCard: View {
    let conceptCount: Int
    let action: () -> Void

    var body: some View {
        CPTappableCard(action: action) {
            HStack(spacing: CPSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: CPCornerRadius.sm)
                        .fill(Color.cpWarning.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.cpWarning)
                }

                VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                    Text("\(conceptCount) concepts are fading")
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    Text("Review to keep your knowledge fresh")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }

                Spacer()

                Text("Review")
                    .font(.cpCalloutBold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, CPSpacing.sm)
                    .padding(.vertical, CPSpacing.xs)
                    .background(Color.cpWarning)
                    .clipShape(Capsule())
            }
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: CPSpacing.md) {
            StreakCard(currentStreak: 7, bestStreak: 14, action: {})
            MoneyScoreCard(score: 65, delta: "+3", action: {})
            LessonCard(title: "Your First Paycheck", subtitle: "Money Basics", estimatedMinutes: 3, isCompleted: false, action: {})
            ReviewCard(conceptCount: 3, action: {})
        }
        .padding()
    }
}
