import SwiftUI

// MARK: - Linear Progress Bar
struct CPProgressBar: View {
    let progress: Double // 0.0 to 1.0
    var height: CGFloat = 8
    var backgroundColor: Color = Color.cpSecondaryLabel.opacity(0.2)
    var foregroundColor: Color = Color.blue

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(backgroundColor)
                    .frame(height: height)

                RoundedRectangle(cornerRadius: height / 2)
                    .fill(foregroundColor)
                    .frame(width: geometry.size.width * min(max(progress, 0), 1), height: height)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Circular Progress
struct CPCircularProgress: View {
    let progress: Double // 0.0 to 1.0
    var lineWidth: CGFloat = 8
    var size: CGFloat = 100
    var backgroundColor: Color = Color.cpSecondaryLabel.opacity(0.2)
    var foregroundGradient: LinearGradient = LinearGradient.cpPrimaryGradient

    var body: some View {
        ZStack {
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: CGFloat(min(max(progress, 0), 1)))
                .stroke(foregroundGradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Segmented Progress (Lesson Progress)
struct CPSegmentedProgress: View {
    let totalSegments: Int
    let completedSegments: Int
    var spacing: CGFloat = 4
    var height: CGFloat = 6
    var completedColor: Color = Color.blue
    var incompleteColor: Color = Color.cpSecondaryLabel.opacity(0.2)

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<totalSegments, id: \.self) { index in
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(index < completedSegments ? completedColor : incompleteColor)
                    .frame(height: height)
            }
        }
    }
}

// MARK: - Score Component Bar
struct CPScoreComponentBar: View {
    let title: String
    let value: Double
    let maxValue: Double
    let color: Color

    var progress: Double {
        guard maxValue > 0 else { return 0 }
        return value / maxValue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.xs) {
            HStack {
                Text(title)
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpSecondaryLabel)

                Spacer()

                Text("\(Int(value))/\(Int(maxValue))")
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpSecondaryLabel)
            }

            CPProgressBar(
                progress: progress,
                height: 6,
                foregroundColor: color
            )
        }
    }
}

#Preview {
    VStack(spacing: CPSpacing.xl) {
        VStack(alignment: .leading, spacing: CPSpacing.sm) {
            Text("Linear Progress")
                .font(.cpHeadline)

            CPProgressBar(progress: 0.7)
        }

        VStack(spacing: CPSpacing.sm) {
            Text("Circular Progress")
                .font(.cpHeadline)

            HStack(spacing: CPSpacing.xl) {
                CPCircularProgress(progress: 0.25, size: 60)
                CPCircularProgress(progress: 0.5, size: 60)
                CPCircularProgress(progress: 0.75, size: 60)
            }
        }

        VStack(alignment: .leading, spacing: CPSpacing.sm) {
            Text("Segmented Progress")
                .font(.cpHeadline)

            CPSegmentedProgress(totalSegments: 8, completedSegments: 5)
        }

        VStack(spacing: CPSpacing.sm) {
            Text("Score Components")
                .font(.cpHeadline)

            CPScoreComponentBar(title: "Knowledge", value: 45, maxValue: 60, color: .cpScoreKnowledge)
            CPScoreComponentBar(title: "Behaviour", value: 18, maxValue: 25, color: .cpScoreBehaviour)
            CPScoreComponentBar(title: "Consistency", value: 12, maxValue: 15, color: .cpScoreConsistency)
        }
    }
    .padding()
}
