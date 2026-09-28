import SwiftUI

// MARK: - Push Notification Setup View
/// Shown after first lesson completion
struct PushNotificationSetupView: View {
    @Environment(AppStateController.self) private var appState
    @State private var selectedTime = Date()
    @State private var showingTimePicker = false

    var body: some View {
        VStack(spacing: CPSpacing.xxl) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 120, height: 120)

                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.blue)
            }

            // Message
            VStack(spacing: CPSpacing.md) {
                Text("When should we remind you?")
                    .font(.cpTitle2)
                    .foregroundStyle(Color.cpLabel)
                    .multilineTextAlignment(.center)

                Text("A daily reminder helps you build your streak. We'll only send what matters.")
                    .font(.cpBody)
                    .foregroundStyle(Color.cpSecondaryLabel)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, CPSpacing.xl)
            }

            // Time Picker Button
            Button {
                showingTimePicker = true
            } label: {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundStyle(Color.blue)

                    Text(formattedTime)
                        .font(.cpBodyBold)
                        .foregroundStyle(Color.cpLabel)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.cpSecondaryLabel)
                }
                .padding(CPSpacing.md)
                .background(Color.cpSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
            }
            .padding(.horizontal, CPSpacing.xl)

            Spacer()

            // CTAs
            VStack(spacing: CPSpacing.md) {
                Button {
                    requestNotificationPermission()
                } label: {
                    Text("Enable reminders")
                }
                .cpPrimaryButton()

                Button {
                    skipNotifications()
                } label: {
                    Text("Maybe later")
                }
                .cpTextButton()
            }
            .padding(.horizontal, CPSpacing.xl)
            .padding(.bottom, CPSpacing.xxl)
        }
        .background(Color.cpBackground)
        .sheet(isPresented: $showingTimePicker) {
            TimePickerSheet(selectedTime: $selectedTime)
        }
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: selectedTime)
    }

    private func requestNotificationPermission() {
        // In real app, request UNUserNotificationCenter authorization
        // For MVP, we'll simulate success
        appState.dataManager.setReminderTime(selectedTime)
        appState.dataManager.enablePushNotifications(true)
        appState.completeOnboarding()
    }

    private func skipNotifications() {
        appState.dataManager.enablePushNotifications(false)
        appState.completeOnboarding()
    }
}

// MARK: - Time Picker Sheet
struct TimePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTime: Date

    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Select time",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()

                Spacer()
            }
            .padding()
            .navigationTitle("Reminder Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    PushNotificationSetupView()
        .environment(AppStateController())
}
