import SwiftUI

struct RootView: View {
    @Environment(AppStateController.self) private var appState

    var body: some View {
        Group {
            switch appState.state {
            case .loading:
                LaunchView()

            case .onboarding(let step):
                OnboardingCoordinator(step: step)

            case .authenticated:
                MainTabView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.state)
        #if DEBUG
        .withDebugMenu()
        #endif
    }
}

// MARK: - Onboarding Coordinator
struct OnboardingCoordinator: View {
    let step: OnboardingStep
    @Environment(AppStateController.self) private var appState

    var body: some View {
        Group {
            switch step {
            case .valueProposition:
                ValuePropCarouselView()

            case .sampleLesson:
                SampleLessonView()

            case .sampleLessonComplete:
                SampleLessonCompleteView()

            case .signUp:
                SignUpView()

            case .goalQuiz:
                GoalQuizView()

            case .pushNotificationSetup:
                PushNotificationSetupView()
            }
        }
    }
}

#Preview {
    RootView()
        .environment(AppStateController())
}
