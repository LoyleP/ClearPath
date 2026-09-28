import SwiftUI

/// Placeholder for the `.unauthenticated` state — will become the
/// real onboarding/sign-in flow.
struct WelcomeView: View {
    @Environment(AppStateController.self) private var appState

    var body: some View {
        VStack(spacing: 16) {
            Text("Welcome to ClearPath")
                .font(.title.bold())
            Text("Onboarding and sign-in go here.")
                .foregroundStyle(.secondary)

            Button("Continue") {
                appState.transition(to: .authenticated)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    WelcomeView()
        .environment(AppStateController())
}
