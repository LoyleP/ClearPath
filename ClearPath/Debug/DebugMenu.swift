import SwiftUI

#if DEBUG
// MARK: - Debug Menu
/// Development-only menu for jumping to specific flows
struct DebugMenu: View {
    @Environment(AppStateController.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // App State Section
                Section("App State") {
                    Button("→ Loading") {
                        appState.forceState(.loading)
                        dismiss()
                    }

                    Button("→ Onboarding: Value Prop") {
                        appState.forceState(.onboarding(.valueProposition))
                        dismiss()
                    }

                    Button("→ Onboarding: Sample Lesson") {
                        appState.forceState(.onboarding(.sampleLesson))
                        dismiss()
                    }

                    Button("→ Onboarding: Sign Up") {
                        appState.forceState(.onboarding(.signUp))
                        dismiss()
                    }

                    Button("→ Onboarding: Goal Quiz") {
                        appState.forceState(.onboarding(.goalQuiz))
                        dismiss()
                    }

                    Button("→ Authenticated (Main App)") {
                        setupAuthenticatedUser()
                        appState.forceState(.authenticated)
                        dismiss()
                    }
                }

                // Quick Actions Section
                Section("Quick Setup") {
                    Button("Setup: New User (No Progress)") {
                        appState.dataManager.resetAllData()
                        setupAuthenticatedUser()
                        appState.forceState(.authenticated)
                        dismiss()
                    }

                    Button("Setup: Active User (Some Progress)") {
                        setupActiveUser()
                        appState.forceState(.authenticated)
                        dismiss()
                    }

                    Button("Setup: Pro User") {
                        setupProUser()
                        appState.forceState(.authenticated)
                        dismiss()
                    }

                    Button("Setup: Trial Ending (Day 7)") {
                        setupTrialEndingUser()
                        appState.forceState(.authenticated)
                        dismiss()
                    }
                }

                // Direct Screen Access
                Section("Open Screens Directly") {
                    NavigationLink("Paywall") {
                        PaywallView()
                    }

                    NavigationLink("Reverse Trial End") {
                        ReverseTrialEndView()
                    }

                    NavigationLink("Money Score Detail") {
                        MoneyScoreView()
                    }

                    NavigationLink("Streak Detail") {
                        StreakDetailView()
                    }

                    NavigationLink("Leagues") {
                        LeaguesView()
                    }

                    NavigationLink("Settings") {
                        SettingsView()
                    }
                }

                // Simulator Direct Access
                Section("Money Lab Simulators") {
                    ForEach(MoneyLabSimulator.allCases) { simulator in
                        NavigationLink(simulator.rawValue) {
                            SimulatorView(simulator: simulator)
                        }
                    }
                }

                // Sample Lessons
                Section("Sample Lessons") {
                    if let lesson = appState.dataManager.tracks.first?.lessons.first {
                        NavigationLink("First Lesson: \(lesson.title)") {
                            LessonView(lesson: lesson)
                        }
                    }

                    NavigationLink("Lesson Complete Screen") {
                        LessonCompleteView(
                            lesson: Lesson.sampleLesson,
                            correctAnswers: 6,
                            totalQuestions: 8
                        )
                    }
                }

                // Data Management
                Section("Data") {
                    Button("Reset All Data", role: .destructive) {
                        appState.dataManager.resetAllData()
                        appState.forceState(.onboarding(.valueProposition))
                        dismiss()
                    }

                    Button("Add 10 Day Streak") {
                        addStreak(days: 10)
                    }

                    Button("Add 5 Completed Lessons") {
                        addCompletedLessons(count: 5)
                    }

                    Button("Trigger Fading Concepts") {
                        triggerFadingConcepts()
                    }
                }
            }
            .navigationTitle("🛠 Debug Menu")
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

    // MARK: - Setup Helpers

    private func setupAuthenticatedUser() {
        appState.dataManager.createUser(
            displayName: "Test User",
            email: "test@example.com",
            provider: .email,
            preferredGoal: .budgeting
        )
    }

    private func setupActiveUser() {
        setupAuthenticatedUser()
        addCompletedLessons(count: 5)
        addStreak(days: 7)
    }

    private func setupProUser() {
        setupActiveUser()
        appState.dataManager.activateProSubscription()
    }

    private func setupTrialEndingUser() {
        setupActiveUser()
        appState.dataManager.startReverseTrial()
        // Simulate day 7 of trial
    }

    private func addStreak(days: Int) {
        let activityDates = (0..<days).compactMap { offset in
            Calendar.current.date(byAdding: .day, value: -offset, to: Date())
        }
        appState.dataManager.debugSetStreak(currentStreak: days, activityDates: activityDates)
    }

    private func addCompletedLessons(count: Int) {
        let lessons = appState.dataManager.tracks.flatMap { $0.lessons }.prefix(count)
        for lesson in lessons {
            appState.dataManager.completeLesson(lesson, correctAnswers: 6, totalQuestions: 8)
        }
    }

    private func triggerFadingConcepts() {
        // Add some concepts that are due for review
        let conceptID = UUID()
        var mastery = ConceptMastery(conceptID: conceptID)
        mastery.level = 2
        mastery.lastReviewDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        appState.dataManager.debugSetConceptMastery(mastery)
    }
}

// MARK: - Debug Floating Button
/// Floating button that appears in DEBUG builds to open debug menu
struct DebugFloatingButton: View {
    @State private var showingDebugMenu = false

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    showingDebugMenu = true
                } label: {
                    Image(systemName: "ladybug.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.red)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingDebugMenu) {
            DebugMenu()
        }
    }
}

// MARK: - View Extension for Debug Overlay
extension View {
    /// Adds debug menu access in DEBUG builds
    func withDebugMenu() -> some View {
        self.overlay {
            #if DEBUG
            DebugFloatingButton()
            #endif
        }
    }
}
#endif
