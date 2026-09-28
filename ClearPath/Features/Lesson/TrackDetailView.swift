import SwiftUI

// MARK: - Track Detail View
struct TrackDetailView: View {
    @Environment(AppStateController.self) private var appState
    let track: Track

    @State private var selectedLesson: Lesson?

    var body: some View {
        ScrollView {
            VStack(spacing: CPSpacing.lg) {
                // Track Header
                TrackHeader(track: track, progress: appState.dataManager.userProgress)

                // Lessons List
                VStack(spacing: CPSpacing.sm) {
                    ForEach(track.lessons) { lesson in
                        LessonRow(
                            lesson: lesson,
                            isCompleted: appState.dataManager.userProgress.completedLessonIDs.contains(lesson.id)
                        ) {
                            selectedLesson = lesson
                        }
                    }
                }
                .padding(.horizontal, CPSpacing.md)
            }
            .padding(.top, CPSpacing.md)
        }
        .background(Color.cpBackground)
        .navigationTitle(track.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedLesson) { lesson in
            LessonView(lesson: lesson)
        }
    }
}

// MARK: - Track Header
struct TrackHeader: View {
    let track: Track
    let progress: UserProgress

    var body: some View {
        VStack(spacing: CPSpacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: track.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(Color.blue)
            }

            // Title & Description
            VStack(spacing: CPSpacing.xxs) {
                Text(track.name)
                    .font(.cpTitle2)
                    .foregroundStyle(Color.cpLabel)

                Text(track.description)
                    .font(.cpBody)
                    .foregroundStyle(Color.cpSecondaryLabel)
            }

            // Progress
            HStack(spacing: CPSpacing.md) {
                CPCircularProgress(
                    progress: track.progressPercentage(for: progress),
                    lineWidth: 6,
                    size: 50
                )

                VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                    Text("\(track.completedLessons(for: progress)) of \(track.totalLessons) lessons")
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    Text("\(Int(track.progressPercentage(for: progress) * 100))% complete")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }

                Spacer()
            }
            .padding(CPSpacing.md)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
            .padding(.horizontal, CPSpacing.md)
        }
    }
}

// MARK: - Lesson Row
struct LessonRow: View {
    let lesson: Lesson
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CPSpacing.md) {
                // Status Icon
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.cpSuccess.opacity(0.2) : Color.cpSecondaryBackground)
                        .frame(width: 40, height: 40)

                    Image(systemName: isCompleted ? "checkmark" : "play.fill")
                        .font(.caption)
                        .foregroundStyle(isCompleted ? Color.cpSuccess : Color.blue)
                }

                // Content
                VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                    Text(lesson.title)
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    HStack(spacing: CPSpacing.xs) {
                        Image(systemName: "clock")
                            .font(.caption2)
                        Text("\(lesson.estimatedMinutes) min")
                            .font(.cpCaption)
                    }
                    .foregroundStyle(Color.cpSecondaryLabel)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.cpTertiaryLabel)
            }
            .padding(CPSpacing.md)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        TrackDetailView(track: Track.allTracks.first!)
    }
    .environment(AppStateController())
}
