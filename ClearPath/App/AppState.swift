import Foundation
import Observation

// MARK: - App State Enum
/// Top-level states the app can be in.
enum AppState: Equatable {
    case loading
    case onboarding(OnboardingStep)
    case authenticated
}

// MARK: - Onboarding Steps
enum OnboardingStep: Equatable {
    case valueProposition      // 3-screen carousel
    case sampleLesson          // Free sample lesson (no account)
    case sampleLessonComplete  // "Nice, that's a lesson!"
    case signUp                // Sign up / Log in choice
    case goalQuiz              // Select financial goal
    case pushNotificationSetup // First lesson completed, request push
}

// MARK: - App State Controller
/// Single source of truth for `AppState`. `RootView` observes this
/// and switches screens accordingly; `ClearPathApp` only creates it
/// and kicks off `initialize()`.
@Observable
@MainActor
final class AppStateController {
    private(set) var state: AppState = .loading

    // App Data Manager - shared across the app
    let dataManager = AppDataManager()

    // Paywall tracking
    var paywallDismissals: Int = 0
    var lastPaywallShown: Date?

    // MARK: - State Transitions
    func transition(to newState: AppState) {
        guard isValidTransition(from: state, to: newState) else {
            #if DEBUG
            print("⚠️ Invalid transition: \(state) → \(newState)")
            #endif
            return
        }

        #if DEBUG
        print("🔄 AppState: \(state) → \(newState)")
        #endif
        state = newState
    }

    private func isValidTransition(from: AppState, to: AppState) -> Bool {
        switch (from, to) {
        // From loading
        case (.loading, .onboarding): return true
        case (.loading, .authenticated): return true

        // From onboarding
        case (.onboarding, .onboarding): return true  // Step changes
        case (.onboarding, .authenticated): return true

        // From authenticated
        case (.authenticated, .onboarding): return true  // Log out
        case (.authenticated, .loading): return true     // Reset

        default: return false
        }
    }

    // MARK: - Initialization
    /// Called once at launch. Checks for existing session.
    func initialize() async {
        // Simulate brief loading
        try? await Task.sleep(for: .milliseconds(500))

        // Check if user exists (in real app, check Keychain/UserDefaults)
        if dataManager.currentUser != nil {
            transition(to: .authenticated)
        } else {
            transition(to: .onboarding(.valueProposition))
        }
    }

    // MARK: - Onboarding Flow
    func advanceOnboarding(to step: OnboardingStep) {
        transition(to: .onboarding(step))
    }

    func completeOnboarding() {
        transition(to: .authenticated)
    }

    // MARK: - Auth Actions
    func signUp(displayName: String, email: String?, provider: AuthProvider, preferredGoal: FinancialGoal?) {
        dataManager.createUser(
            displayName: displayName,
            email: email,
            provider: provider,
            preferredGoal: preferredGoal
        )
        completeOnboarding()
    }

    func signIn(email: String) {
        // Mock sign in - in real app, verify with backend
        dataManager.createUser(
            displayName: "Returning User",
            email: email,
            provider: .email,
            preferredGoal: nil
        )
        completeOnboarding()
    }

    func signOut() {
        dataManager.resetAllData()
        transition(to: .onboarding(.valueProposition))
    }

    func logout() {
        // Alias for signOut - keeps data but clears session
        transition(to: .onboarding(.valueProposition))
    }

    // MARK: - Paywall Logic
    var canShowPaywall: Bool {
        // Max 1 per 24 hours
        if let lastShown = lastPaywallShown {
            let hoursSinceLastShown = Date().timeIntervalSince(lastShown) / 3600
            if hoursSinceLastShown < 24 {
                return false
            }
        }

        // After 3 dismissals, suppress for 7 days
        if paywallDismissals >= 3 {
            if let lastShown = lastPaywallShown {
                let daysSinceLastShown = Date().timeIntervalSince(lastShown) / 86400
                if daysSinceLastShown < 7 {
                    return false
                }
            }
        }

        return true
    }

    func recordPaywallShown() {
        lastPaywallShown = Date()
    }

    func recordPaywallDismissed() {
        paywallDismissals += 1
    }

    func resetPaywallTracking() {
        paywallDismissals = 0
        lastPaywallShown = nil
    }
}
