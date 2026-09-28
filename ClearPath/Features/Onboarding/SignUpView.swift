import SwiftUI

// MARK: - Sign Up View
struct SignUpView: View {
    @Environment(AppStateController.self) private var appState
    @State private var isSignUp = true
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var showingEmailForm = false

    var body: some View {
        VStack(spacing: CPSpacing.xl) {
            // Header
            VStack(spacing: CPSpacing.sm) {
                Text(isSignUp ? "Create your account" : "Welcome back")
                    .font(.cpTitle)
                    .foregroundStyle(Color.cpLabel)

                Text(isSignUp ? "Save your progress and build your streak" : "Sign in to continue your journey")
                    .font(.cpBody)
                    .foregroundStyle(Color.cpSecondaryLabel)
            }
            .padding(.top, CPSpacing.xxl)

            Spacer()

            // Social Sign In Buttons
            VStack(spacing: CPSpacing.md) {
                AppleSignInButton {
                    // Mock Apple Sign In
                    handleSocialSignIn(provider: .apple, displayName: "Apple User")
                }

                GoogleSignInButton {
                    // Mock Google Sign In
                    handleSocialSignIn(provider: .google, displayName: "Google User")
                }

                // Divider
                HStack {
                    Rectangle()
                        .fill(Color.cpSecondaryLabel.opacity(0.3))
                        .frame(height: 1)

                    Text("or")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)

                    Rectangle()
                        .fill(Color.cpSecondaryLabel.opacity(0.3))
                        .frame(height: 1)
                }
                .padding(.vertical, CPSpacing.sm)

                // Email Option
                Button {
                    showingEmailForm = true
                } label: {
                    HStack(spacing: CPSpacing.sm) {
                        Image(systemName: "envelope.fill")
                            .font(.title3)
                        Text("Continue with Email")
                            .font(.cpBodyBold)
                    }
                }
                .cpSecondaryButton()
            }
            .padding(.horizontal, CPSpacing.xl)

            Spacer()

            // Toggle Sign Up / Log In
            Button {
                isSignUp.toggle()
            } label: {
                Text(isSignUp ? "Already have an account? Log in" : "Don't have an account? Sign up")
                    .font(.cpCallout)
            }
            .cpTextButton()
            .padding(.bottom, CPSpacing.xl)
        }
        .background(Color.cpBackground)
        .sheet(isPresented: $showingEmailForm) {
            EmailAuthSheet(isSignUp: isSignUp) { name, emailAddress in
                handleEmailSignIn(displayName: name, email: emailAddress)
            }
        }
    }

    private func handleSocialSignIn(provider: AuthProvider, displayName: String) {
        // For MVP, immediately proceed to goal quiz
        appState.dataManager.createUser(
            displayName: displayName,
            email: nil,
            provider: provider,
            preferredGoal: nil
        )
        appState.advanceOnboarding(to: .goalQuiz)
    }

    private func handleEmailSignIn(displayName: String, email: String) {
        appState.dataManager.createUser(
            displayName: displayName,
            email: email,
            provider: .email,
            preferredGoal: nil
        )
        appState.advanceOnboarding(to: .goalQuiz)
    }
}

// MARK: - Email Auth Sheet
struct EmailAuthSheet: View {
    let isSignUp: Bool
    let onComplete: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""

    var isValid: Bool {
        !email.isEmpty && !password.isEmpty && (isSignUp ? !displayName.isEmpty : true)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: CPSpacing.lg) {
                if isSignUp {
                    TextField("Display name", text: $displayName)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                }

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(isSignUp ? .newPassword : .password)

                Spacer()

                Button {
                    onComplete(isSignUp ? displayName : "User", email)
                    dismiss()
                } label: {
                    Text(isSignUp ? "Create Account" : "Sign In")
                }
                .cpPrimaryButton(isEnabled: isValid)
                .disabled(!isValid)
            }
            .padding(CPSpacing.xl)
            .navigationTitle(isSignUp ? "Sign Up" : "Log In")
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
}

#Preview {
    SignUpView()
        .environment(AppStateController())
}
