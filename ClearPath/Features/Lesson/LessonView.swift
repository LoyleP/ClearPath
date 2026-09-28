import SwiftUI

// MARK: - Lesson View
struct LessonView: View {
    @Environment(AppStateController.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let lesson: Lesson

    @State private var currentQuestionIndex = 0
    @State private var selectedAnswerID: UUID?
    @State private var showingFeedback = false
    @State private var isCorrect = false
    @State private var correctAnswers = 0
    @State private var requeuedQuestions: [Question] = []
    @State private var showingCompletion = false

    private var allQuestions: [Question] {
        lesson.questions + requeuedQuestions
    }

    private var currentQuestion: Question? {
        guard currentQuestionIndex < allQuestions.count else { return nil }
        return allQuestions[currentQuestionIndex]
    }

    private var progress: Double {
        guard allQuestions.count > 0 else { return 0 }
        return Double(currentQuestionIndex) / Double(allQuestions.count)
    }

    var body: some View {
        NavigationStack {
            if showingCompletion {
                LessonCompleteView(
                    lesson: lesson,
                    correctAnswers: correctAnswers,
                    totalQuestions: lesson.questions.count
                )
            } else if let question = currentQuestion {
                VStack(spacing: 0) {
                    // Header with progress
                    LessonHeader(
                        progress: progress,
                        currentIndex: currentQuestionIndex,
                        totalCount: allQuestions.count,
                        onClose: { dismiss() }
                    )

                    Spacer()

                    // Question Content
                    QuestionContentView(
                        question: question,
                        selectedAnswerID: $selectedAnswerID,
                        showingFeedback: showingFeedback
                    )

                    Spacer()

                    // Feedback or Submit
                    VStack(spacing: CPSpacing.md) {
                        if showingFeedback {
                            QuestionFeedbackView(
                                isCorrect: isCorrect,
                                explanation: question.explanation,
                                sourceCitation: question.sourceCitation
                            )
                        }

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
        }
        .interactiveDismissDisabled(true)
    }

    private func submitAnswer() {
        guard let selectedID = selectedAnswerID,
              let question = currentQuestion,
              let selectedOption = question.options?.first(where: { $0.id == selectedID }) else {
            return
        }

        isCorrect = selectedOption.isCorrect

        if isCorrect {
            correctAnswers += 1
            appState.dataManager.recordQuestionAnswer(conceptID: question.conceptID, isCorrect: true)
        } else {
            // Requeue wrong answer
            requeuedQuestions.append(question)
            appState.dataManager.recordQuestionAnswer(conceptID: question.conceptID, isCorrect: false)
        }

        withAnimation {
            showingFeedback = true
        }
    }

    private func moveToNextQuestion() {
        if currentQuestionIndex < allQuestions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswerID = nil
            showingFeedback = false
            isCorrect = false
        } else {
            // Lesson complete
            appState.dataManager.completeLesson(
                lesson,
                correctAnswers: correctAnswers,
                totalQuestions: lesson.questions.count
            )

            withAnimation {
                showingCompletion = true
            }
        }
    }
}

// MARK: - Lesson Header
struct LessonHeader: View {
    let progress: Double
    let currentIndex: Int
    let totalCount: Int
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: CPSpacing.sm) {
            HStack {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }

                Spacer()

                Text("\(currentIndex + 1) of \(totalCount)")
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpSecondaryLabel)
            }

            CPSegmentedProgress(
                totalSegments: totalCount,
                completedSegments: currentIndex
            )
        }
        .padding(.horizontal, CPSpacing.md)
        .padding(.top, CPSpacing.md)
    }
}

// MARK: - Question Content View
struct QuestionContentView: View {
    let question: Question
    @Binding var selectedAnswerID: UUID?
    let showingFeedback: Bool

    var body: some View {
        VStack(spacing: CPSpacing.xl) {
            // Question Type Badge
            HStack {
                Image(systemName: question.type.icon)
                    .font(.caption)
                Text(question.type.rawValue)
                    .font(.cpCaption)
            }
            .foregroundStyle(Color.cpSecondaryLabel)
            .padding(.horizontal, CPSpacing.sm)
            .padding(.vertical, CPSpacing.xxs)
            .background(Color.cpSecondaryBackground)
            .clipShape(Capsule())

            // Question Text
            Text(question.content)
                .font(.cpQuestionText)
                .foregroundStyle(Color.cpLabel)
                .multilineTextAlignment(.center)
                .padding(.horizontal, CPSpacing.md)

            // Answer Options
            if let options = question.options {
                VStack(spacing: CPSpacing.sm) {
                    ForEach(options) { option in
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
        }
    }
}

// MARK: - Question Feedback View
struct QuestionFeedbackView: View {
    let isCorrect: Bool
    let explanation: String
    let sourceCitation: String?

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

            if let citation = sourceCitation {
                HStack(spacing: CPSpacing.xxs) {
                    Image(systemName: "doc.text")
                        .font(.caption)
                    Text(citation)
                        .font(.cpCaption)
                }
                .foregroundStyle(Color.cpTertiaryLabel)
            }
        }
        .padding(CPSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isCorrect ? Color.cpSuccess.opacity(0.1) : Color.cpError.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
    }
}

#Preview {
    LessonView(lesson: Lesson.sampleLesson)
        .environment(AppStateController())
}
