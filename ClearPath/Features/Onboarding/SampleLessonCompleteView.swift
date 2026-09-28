import SwiftUI

// MARK: - Sample Lesson Complete View
struct SampleLessonCompleteView: View {
    @Environment(AppStateController.self) private var appState

    var body: some View {
        VStack(spacing: CPSpacing.xxl) {
            Spacer()

            // Success Icon
            ZStack {
                Circle()
                    .fill(Color.cpSuccess.opacity(0.15))
                    .frame(width: 160, height: 160)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.cpSuccess)
            }

            // Message
            VStack(spacing: CPSpacing.md) {
                Text("Nice, that's a lesson!")
                    .font(.cpTitle)
                    .foregroundStyle(Color.cpLabel)
                    .multilineTextAlignment(.center)

                Text("Create an account to save your progress and keep your streak going.")
                    .font(.cpBody)
                    .foregroundStyle(Color.cpSecondaryLabel)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, CPSpacing.xl)
            }

            Spacer()

            // CTAs
            VStack(spacing: CPSpacing.md) {
                Button {
                    appState.advanceOnboarding(to: .signUp)
                } label: {
                    Text("Create account")
                }
                .cpPrimaryButton()

                Button {
                    appState.advanceOnboarding(to: .signUp)
                } label: {
                    Text("I already have an account")
                }
                .cpSecondaryButton()
            }
            .padding(.horizontal, CPSpacing.xl)
            .padding(.bottom, CPSpacing.xxl)
        }
        .background(Color.cpBackground)
    }
}

#Preview {
    SampleLessonCompleteView()
        .environment(AppStateController())
}
