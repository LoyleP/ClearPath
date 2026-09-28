import SwiftUI

// MARK: - Sample Lesson View
/// Free sample lesson shown during onboarding (no account required)
struct SampleLessonView: View {
    @Environment(AppStateController.self) private var appState
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswerID: UUID?
    @State private var showingFeedback = false
    @State private var isCorrect = false
    @State private var correctAnswers = 0

    private let questions: [SampleQuestion] = SampleQuestion.sampleQuestions

    private var currentQuestion: SampleQuestion {
        questions[currentQuestionIndex]
    }

    private var progress: Double {
        Double(currentQuestionIndex) / Double(questions.count)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with progress
            VStack(spacing: CPSpacing.sm) {
                HStack {
                    Button {
                        appState.advanceOnboarding(to: .valueProposition)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundStyle(Color.cpSecondaryLabel)
                    }

                    Spacer()

                    Text("\(currentQuestionIndex + 1) of \(questions.count)")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }

                CPProgressBar(progress: progress, height: 6)
            }
            .padding(.horizontal, CPSpacing.md)
            .padding(.top, CPSpacing.md)

            Spacer()

            // Question Content
            VStack(spacing: CPSpacing.xl) {
                Text(currentQuestion.content)
                    .font(.cpQuestionText)
                    .foregroundStyle(Color.cpLabel)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, CPSpacing.md)

                // Answer Options
                VStack(spacing: CPSpacing.sm) {
                    ForEach(currentQuestion.options) { option in
                        AnswerOptionButton(
                            text: option.content,
                            isSelected: selectedAnswerID == option.id,
                            isCorrect: showingFeedback ? option.isCorrect : nil
                        ) {
                            if !showingFeedback {
                                selectedAnswerID = option.id
                            }
                        }
                    }
                }
                .padding(.horizontal, CPSpacing.md)
            }

            Spacer()

            // Feedback or Submit
            VStack(spacing: CPSpacing.md) {
                if showingFeedback {
                    // Feedback View
                    FeedbackCard(
                        isCorrect: isCorrect,
                        explanation: currentQuestion.explanation
                    )
                }

                // Action Button
                Button {
                    if showingFeedback {
                        moveToNextQuestion()
                    } else {
                        submitAnswer()
                    }
                } label: {
                    Text(showingFeedback ? "Continue" : "Check")
                }
                .cpPrimaryButton(isEnabled: selectedAnswerID != nil)
                .disabled(selectedAnswerID == nil && !showingFeedback)
            }
            .padding(.horizontal, CPSpacing.md)
            .padding(.bottom, CPSpacing.xl)
        }
        .background(Color.cpBackground)
    }

    private func submitAnswer() {
        guard let selectedID = selectedAnswerID,
              let selectedOption = currentQuestion.options.first(where: { $0.id == selectedID }) else {
            return
        }

        isCorrect = selectedOption.isCorrect
        if isCorrect {
            correctAnswers += 1
        }

        withAnimation {
            showingFeedback = true
        }
    }

    private func moveToNextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswerID = nil
            showingFeedback = false
            isCorrect = false
        } else {
            // Sample lesson complete
            appState.advanceOnboarding(to: .sampleLessonComplete)
        }
    }
}

// MARK: - Sample Question Model
struct SampleQuestion: Identifiable {
    let id = UUID()
    let content: String
    let options: [AnswerOption]
    let explanation: String

    static let sampleQuestions: [SampleQuestion] = [
        SampleQuestion(
            content: "What's the difference between saving and investing?",
            options: [
                AnswerOption(content: "They're the same thing"),
                AnswerOption(content: "Saving is for short-term, investing is for long-term growth", isCorrect: true),
                AnswerOption(content: "Investing is only for rich people"),
                AnswerOption(content: "Saving always earns more than investing")
            ],
            explanation: "Saving is keeping money safe for short-term needs (like an emergency fund), while investing puts money to work for long-term growth, accepting some risk for potentially higher returns."
        ),
        SampleQuestion(
            content: "What's a good rule of thumb for an emergency fund?",
            options: [
                AnswerOption(content: "1 month of expenses"),
                AnswerOption(content: "3-6 months of expenses", isCorrect: true),
                AnswerOption(content: "$500 total"),
                AnswerOption(content: "As much as possible")
            ],
            explanation: "Financial experts recommend 3-6 months of essential expenses. This covers most emergencies like job loss or unexpected repairs without going into debt."
        ),
        SampleQuestion(
            content: "What is compound interest?",
            options: [
                AnswerOption(content: "Interest only on your original amount"),
                AnswerOption(content: "Interest on your interest, creating exponential growth", isCorrect: true),
                AnswerOption(content: "A type of bank fee"),
                AnswerOption(content: "The same as simple interest")
            ],
            explanation: "Compound interest means you earn interest on both your original amount AND previous interest earned. Over time, this creates exponential growth — Einstein allegedly called it 'the eighth wonder of the world.'"
        )
    ]
}

// MARK: - Feedback Card
struct FeedbackCard: View {
    let isCorrect: Bool
    let explanation: String

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.sm) {
            HStack(spacing: CPSpacing.sm) {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(isCorrect ? Color.cpSuccess : Color.cpError)

                Text(isCorrect ? "Correct!" : "Not quite")
                    .font(.cpHeadline)
                    .foregroundStyle(Color.cpLabel)
            }

            Text(explanation)
                .font(.cpBody)
                .foregroundStyle(Color.cpSecondaryLabel)
        }
        .padding(CPSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isCorrect ? Color.cpSuccess.opacity(0.1) : Color.cpError.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
    }
}

#Preview {
    SampleLessonView()
        .environment(AppStateController())
}
