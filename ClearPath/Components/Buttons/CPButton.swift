import SwiftUI

// MARK: - ClearPath Button Styles

struct CPPrimaryButtonStyle: ButtonStyle {
    let isEnabled: Bool

    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.cpBodyBold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: CPTouchTarget.comfortable)
            .background(isEnabled ? Color.blue : Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct CPSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.cpBodyBold)
            .foregroundStyle(Color.blue)
            .frame(maxWidth: .infinity)
            .frame(height: CPTouchTarget.comfortable)
            .background(Color.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct CPTextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.cpBody)
            .foregroundStyle(Color.blue)
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

struct CPDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.cpBodyBold)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: CPTouchTarget.comfortable)
            .background(Color.cpError)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Button View Modifiers
extension View {
    func cpPrimaryButton(isEnabled: Bool = true) -> some View {
        buttonStyle(CPPrimaryButtonStyle(isEnabled: isEnabled))
    }

    func cpSecondaryButton() -> some View {
        buttonStyle(CPSecondaryButtonStyle())
    }

    func cpTextButton() -> some View {
        buttonStyle(CPTextButtonStyle())
    }

    func cpDestructiveButton() -> some View {
        buttonStyle(CPDestructiveButtonStyle())
    }
}

// MARK: - Answer Option Button
struct AnswerOptionButton: View {
    let text: String
    let isSelected: Bool
    let isCorrect: Bool?
    let action: () -> Void

    private var backgroundColor: Color {
        if let isCorrect {
            return isCorrect ? Color.cpSuccess.opacity(0.2) : Color.cpError.opacity(0.2)
        }
        return isSelected ? Color.blue.opacity(0.2) : Color.cpSecondaryBackground
    }

    private var borderColor: Color {
        if let isCorrect {
            return isCorrect ? Color.cpSuccess : Color.cpError
        }
        return isSelected ? Color.blue : Color.clear
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.cpAnswerOption)
                    .foregroundStyle(Color.cpLabel)
                    .multilineTextAlignment(.leading)

                Spacer()

                if let isCorrect {
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(isCorrect ? Color.cpSuccess : Color.cpError)
                }
            }
            .padding(CPSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: CPCornerRadius.md)
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Social Sign In Buttons
struct AppleSignInButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CPSpacing.sm) {
                Image(systemName: "apple.logo")
                    .font(.title3)
                Text("Continue with Apple")
                    .font(.cpBodyBold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: CPTouchTarget.comfortable)
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
        }
    }
}

struct GoogleSignInButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CPSpacing.sm) {
                Image(systemName: "g.circle.fill")
                    .font(.title3)
                Text("Continue with Google")
                    .font(.cpBodyBold)
            }
            .foregroundStyle(Color.cpLabel)
            .frame(maxWidth: .infinity)
            .frame(height: CPTouchTarget.comfortable)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: CPCornerRadius.md)
                    .stroke(Color.cpSecondaryLabel.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    VStack(spacing: CPSpacing.md) {
        Button("Primary Button") {}
            .cpPrimaryButton()

        Button("Secondary Button") {}
            .cpSecondaryButton()

        Button("Destructive Button") {}
            .cpDestructiveButton()

        AppleSignInButton {}
        GoogleSignInButton {}

        AnswerOptionButton(text: "This is an answer option", isSelected: false, isCorrect: nil) {}
        AnswerOptionButton(text: "Selected answer", isSelected: true, isCorrect: nil) {}
        AnswerOptionButton(text: "Correct answer", isSelected: true, isCorrect: true) {}
        AnswerOptionButton(text: "Wrong answer", isSelected: true, isCorrect: false) {}
    }
    .padding()
}
