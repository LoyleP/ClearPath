import SwiftUI

// MARK: - Money Score View
struct MoneyScoreView: View {
    @Environment(AppStateController.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var showingBehaviourCheckIn = false
    @State private var showingMethodology = false

    private var moneyScore: MoneyScore {
        appState.dataManager.moneyScore
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CPSpacing.xl) {
                    // Main Score Display
                    ScoreHeroSection(score: moneyScore)

                    // Component Breakdown
                    ScoreComponentsSection(score: moneyScore)

                    // Knowledge Benchmark
                    KnowledgeBenchmarkCard(knowledgeScore: moneyScore.knowledge)

                    // Fading Concepts Alert
                    if !appState.dataManager.fadingConcepts.isEmpty {
                        FadingConceptsCard(count: appState.dataManager.fadingConcepts.count)
                    }

                    // Monthly Check-in
                    if appState.dataManager.behaviourCheckIn.isCheckInDue {
                        BehaviourCheckInCard(action: { showingBehaviourCheckIn = true })
                    }

                    // Track List
                    TrackListSection(tracks: appState.dataManager.tracks, progress: appState.dataManager.userProgress)

                    // Methodology Link
                    Button {
                        showingMethodology = true
                    } label: {
                        HStack {
                            Image(systemName: "info.circle")
                            Text("How this is calculated")
                        }
                        .font(.cpCallout)
                        .foregroundStyle(Color.blue)
                    }
                    .padding(.top, CPSpacing.md)
                }
                .padding(.horizontal, CPSpacing.md)
                .padding(.top, CPSpacing.md)
            }
            .background(Color.cpBackground)
            .navigationTitle("Money Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingBehaviourCheckIn) {
                BehaviourCheckInView()
            }
            .sheet(isPresented: $showingMethodology) {
                MethodologyView()
            }
        }
    }
}

// MARK: - Score Hero Section
struct ScoreHeroSection: View {
    let score: MoneyScore

    var body: some View {
        VStack(spacing: CPSpacing.md) {
            // Large Score Circle
            ZStack {
                Circle()
                    .stroke(Color.cpSecondaryLabel.opacity(0.2), lineWidth: 12)
                    .frame(width: 180, height: 180)

                Circle()
                    .trim(from: 0, to: CGFloat(score.totalScore) / 100)
                    .stroke(
                        LinearGradient.cpPrimaryGradient,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: score.totalScore)

                VStack(spacing: CPSpacing.xxs) {
                    Text("\(score.scoreInt)")
                        .font(.cpScoreNumber)
                        .foregroundStyle(Color.cpLabel)

                    Text("out of 100")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }
            }

            // Weekly Delta
            HStack(spacing: CPSpacing.xs) {
                Image(systemName: score.weeklyDelta >= 0 ? "arrow.up.right" : "arrow.down.right")
                    .foregroundStyle(score.weeklyDelta >= 0 ? Color.cpSuccess : Color.cpError)

                Text(score.weeklyDeltaFormatted)
                    .font(.cpHeadline)
                    .foregroundStyle(score.weeklyDelta >= 0 ? Color.cpSuccess : Color.cpError)

                Text("this week")
                    .font(.cpBody)
                    .foregroundStyle(Color.cpSecondaryLabel)
            }
        }
    }
}

// MARK: - Score Components Section
struct ScoreComponentsSection: View {
    let score: MoneyScore

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.md) {
            Text("Score Breakdown")
                .font(.cpHeadline)
                .foregroundStyle(Color.cpLabel)

            VStack(spacing: CPSpacing.sm) {
                CPScoreComponentBar(
                    title: "Knowledge",
                    value: score.knowledge,
                    maxValue: 60,
                    color: .cpScoreKnowledge
                )

                CPScoreComponentBar(
                    title: "Behaviour",
                    value: score.behaviour,
                    maxValue: 25,
                    color: .cpScoreBehaviour
                )

                CPScoreComponentBar(
                    title: "Consistency",
                    value: score.consistency,
                    maxValue: 15,
                    color: .cpScoreConsistency
                )
            }
            .padding(CPSpacing.md)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
        }
    }
}

// MARK: - Knowledge Benchmark Card
struct KnowledgeBenchmarkCard: View {
    let knowledgeScore: Double

    private var knowledgePercentage: Int {
        Int((knowledgeScore / 60.0) * 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.sm) {
            Text("How You Compare")
                .font(.cpHeadline)
                .foregroundStyle(Color.cpLabel)

            VStack(alignment: .leading, spacing: CPSpacing.md) {
                Text("Your knowledge converts to **\(knowledgePercentage)% correct**.")
                    .font(.cpBody)
                    .foregroundStyle(Color.cpLabel)

                HStack(spacing: CPSpacing.xl) {
                    BenchmarkItem(label: "US Adults", value: "49%")
                    BenchmarkItem(label: "Gen Z", value: "38%")
                }

                Text("Source: TIAA-GFLEC 2025")
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpTertiaryLabel)
            }
            .padding(CPSpacing.md)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
        }
    }
}

// MARK: - Benchmark Item
struct BenchmarkItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.xxs) {
            Text(label)
                .font(.cpCaption)
                .foregroundStyle(Color.cpSecondaryLabel)
            Text(value)
                .font(.cpHeadline)
                .foregroundStyle(Color.cpLabel)
        }
    }
}

// MARK: - Fading Concepts Card
struct FadingConceptsCard: View {
    let count: Int

    var body: some View {
        HStack(spacing: CPSpacing.md) {
            ZStack {
                Circle()
                    .fill(Color.cpWarning.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(Color.cpWarning)
            }

            VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                Text("\(count) concepts are fading")
                    .font(.cpHeadline)
                    .foregroundStyle(Color.cpLabel)

                Text("Review them to keep your score up")
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpSecondaryLabel)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(Color.cpSecondaryLabel)
        }
        .padding(CPSpacing.md)
        .background(Color.cpWarning.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
    }
}

// MARK: - Behaviour Check-In Card
struct BehaviourCheckInCard: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CPSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.cpScoreBehaviour.opacity(0.2))
                        .frame(width: 44, height: 44)

                    Image(systemName: "list.bullet.clipboard.fill")
                        .foregroundStyle(Color.cpScoreBehaviour)
                }

                VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                    Text("Monthly Check-In")
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    Text("Update your behaviour score")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }

                Spacer()

                Text("Start")
                    .font(.cpCalloutBold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, CPSpacing.sm)
                    .padding(.vertical, CPSpacing.xs)
                    .background(Color.cpScoreBehaviour)
                    .clipShape(Capsule())
            }
            .padding(CPSpacing.md)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Track List Section
struct TrackListSection: View {
    let tracks: [Track]
    let progress: UserProgress

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.sm) {
            Text("All Tracks")
                .font(.cpHeadline)
                .foregroundStyle(Color.cpLabel)

            VStack(spacing: CPSpacing.xs) {
                ForEach(tracks) { track in
                    NavigationLink {
                        TrackDetailView(track: track)
                    } label: {
                        HStack(spacing: CPSpacing.md) {
                            Image(systemName: track.icon)
                                .font(.title3)
                                .foregroundStyle(Color.blue)
                                .frame(width: 30)

                            Text(track.name)
                                .font(.cpBody)
                                .foregroundStyle(Color.cpLabel)

                            Spacer()

                            Text("\(track.completedLessons(for: progress))/\(track.totalLessons)")
                                .font(.cpCaption)
                                .foregroundStyle(Color.cpSecondaryLabel)

                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(Color.cpTertiaryLabel)
                        }
                        .padding(CPSpacing.sm)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(CPSpacing.sm)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
        }
    }
}

// MARK: - Behaviour Check-In View
struct BehaviourCheckInView: View {
    @Environment(AppStateController.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var responses: [BehaviourQuestion: Bool] = [:]
    @State private var currentIndex = 0

    private let questions = BehaviourQuestion.allCases

    var body: some View {
        NavigationStack {
            VStack(spacing: CPSpacing.xl) {
                // Progress
                CPProgressBar(progress: Double(currentIndex) / Double(questions.count))
                    .padding(.horizontal, CPSpacing.md)

                Spacer()

                // Question
                if currentIndex < questions.count {
                    let question = questions[currentIndex]

                    VStack(spacing: CPSpacing.xl) {
                        Text(question.question)
                            .font(.cpTitle3)
                            .foregroundStyle(Color.cpLabel)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, CPSpacing.xl)

                        HStack(spacing: CPSpacing.lg) {
                            Button {
                                responses[question] = true
                                nextQuestion()
                            } label: {
                                Text("Yes")
                                    .font(.cpHeadline)
                                    .frame(width: 100, height: 50)
                            }
                            .cpPrimaryButton()

                            Button {
                                responses[question] = false
                                nextQuestion()
                            } label: {
                                Text("No")
                                    .font(.cpHeadline)
                                    .frame(width: 100, height: 50)
                            }
                            .cpSecondaryButton()
                        }
                    }
                }

                Spacer()

                // Info
                InfoBox(text: "Based on your answers (self-reported, not verified)")
                    .padding(.horizontal, CPSpacing.md)
                    .padding(.bottom, CPSpacing.xl)
            }
            .navigationTitle("Monthly Check-In")
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

    private func nextQuestion() {
        if currentIndex < questions.count - 1 {
            withAnimation {
                currentIndex += 1
            }
        } else {
            // Complete check-in
            appState.dataManager.completeBehaviourCheckIn(responses: responses)
            dismiss()
        }
    }
}

// MARK: - Methodology View
struct MethodologyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CPSpacing.xl) {
                    MethodologySection(
                        title: "Knowledge (up to 60 points)",
                        content: """
                        • ~180 concepts tracked
                        • Each concept: mastery level 0-5
                        • Each concept: importance weight 1-3
                        • Mastery decays over time without review
                        • Only rises on first-try correct answers
                        """
                    )

                    MethodologySection(
                        title: "Behaviour (up to 25 points)",
                        content: """
                        • Monthly check-in (8 questions, self-reported)
                        • Labelled "Based on your answers"
                        • One verified action: Money Lab with real numbers
                        """
                    )

                    MethodologySection(
                        title: "Consistency (up to 15 points)",
                        content: """
                        • Average active days per week
                        • Calculated over last 8 weeks
                        • Maxes out at 5 days/week
                        • Cannot game by doing more than 5 days
                        """
                    )

                    MethodologySection(
                        title: "Knowledge Decay",
                        content: """
                        Level 1: decays after 3 days
                        Level 2: decays after 7 days
                        Level 3: decays after 21 days
                        Level 4: decays after 60 days
                        Level 5: decays after 180 days
                        """
                    )
                }
                .padding(CPSpacing.md)
            }
            .background(Color.cpBackground)
            .navigationTitle("How It Works")
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

// MARK: - Methodology Section
struct MethodologySection: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.sm) {
            Text(title)
                .font(.cpHeadline)
                .foregroundStyle(Color.cpLabel)

            Text(content)
                .font(.cpBody)
                .foregroundStyle(Color.cpSecondaryLabel)
        }
        .padding(CPSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
    }
}

#Preview {
    MoneyScoreView()
        .environment(AppStateController())
}
