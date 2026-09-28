import SwiftUI
import StoreKit

// MARK: - Settings View
struct SettingsView: View {
    @Environment(AppStateController.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                // Notifications Section
                Section {
                    NavigationLink {
                        NotificationPreferencesView()
                    } label: {
                        SettingsRow(icon: "bell.fill", title: "Notification Preferences", color: .orange)
                    }

                    NavigationLink {
                        ReminderTimeView()
                    } label: {
                        SettingsRow(icon: "clock.fill", title: "Daily Reminder Time", color: .blue)
                    }

                    NavigationLink {
                        StreakShieldSettingsView()
                    } label: {
                        SettingsRow(icon: "shield.fill", title: "Streak Shields", color: .cpStreakShield)
                    }
                } header: {
                    Text("Reminders")
                }

                // Subscription Section
                Section {
                    Button {
                        openManageSubscriptions()
                    } label: {
                        SettingsRow(icon: "creditcard.fill", title: "Manage Subscription", color: .purple)
                    }

                    Button {
                        restorePurchases()
                    } label: {
                        SettingsRow(icon: "arrow.clockwise", title: "Restore Purchases", color: .green)
                    }
                } header: {
                    Text("Subscription")
                }

                // Privacy Section
                Section {
                    NavigationLink {
                        DataPrivacyView()
                    } label: {
                        SettingsRow(icon: "hand.raised.fill", title: "Data & Privacy", color: .blue)
                    }
                } header: {
                    Text("Privacy")
                }

                // Transparency Section
                Section {
                    NavigationLink {
                        HowWeMakeMoneyView()
                    } label: {
                        SettingsRow(icon: "dollarsign.circle.fill", title: "How We Make Money", color: .green)
                    }

                    NavigationLink {
                        ContentStandardsView()
                    } label: {
                        SettingsRow(icon: "checkmark.seal.fill", title: "Content Standards", color: .blue)
                    }
                } header: {
                    Text("Transparency")
                }

                // Account Section
                Section {
                    Button(role: .destructive) {
                        handleLogout()
                    } label: {
                        SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Log Out", color: .red)
                    }
                } header: {
                    Text("Account")
                }

                // App Info
                Section {
                    HStack {
                        Text("Version")
                            .foregroundStyle(Color.cpLabel)
                        Spacer()
                        Text("1.0.0 (MVP)")
                            .foregroundStyle(Color.cpSecondaryLabel)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
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

    private func openManageSubscriptions() {
        // In real app, use StoreKit's showManageSubscriptions
        // For MVP, show alert
        Task {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                try? await AppStore.showManageSubscriptions(in: windowScene)
            }
        }
    }

    private func restorePurchases() {
        // In real app, sync with AppStore
        // For MVP, this is a mock
        Task {
            // await StoreKit.AppStore.sync()
        }
    }

    private func handleLogout() {
        appState.logout()
        dismiss()
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: CPSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(color)
                    .frame(width: 28, height: 28)

                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(.white)
            }

            Text(title)
                .font(.cpBody)
                .foregroundStyle(Color.cpLabel)
        }
    }
}

// MARK: - Notification Preferences View
struct NotificationPreferencesView: View {
    @State private var dailyReminder = true
    @State private var streakAtRisk = true
    @State private var weeklyRecap = true
    @State private var timelyEvents = true

    var body: some View {
        List {
            Section {
                NotificationToggle(
                    title: "Daily Reminder",
                    description: "Get reminded at your chosen time",
                    isOn: $dailyReminder
                )

                NotificationToggle(
                    title: "Streak at Risk",
                    description: "Get notified if your streak is at risk (8 PM)",
                    isOn: $streakAtRisk
                )

                NotificationToggle(
                    title: "Weekly Recap",
                    description: "Sunday summary of your progress",
                    isOn: $weeklyRecap
                )

                NotificationToggle(
                    title: "Timely Money Events",
                    description: "IRA deadlines, W-2 season, etc.",
                    isOn: $timelyEvents
                )
            } footer: {
                Text("Maximum 1 notification per day to respect your time.")
                    .font(.cpCaption)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Notification Toggle
struct NotificationToggle: View {
    let title: String
    let description: String
    @Binding var isOn: Bool

    var body: some View {
        Toggle(isOn: $isOn) {
            VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                Text(title)
                    .font(.cpBody)
                    .foregroundStyle(Color.cpLabel)

                Text(description)
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpSecondaryLabel)
            }
        }
        .tint(Color.blue)
    }
}

// MARK: - Reminder Time View
struct ReminderTimeView: View {
    @Environment(AppStateController.self) private var appState
    @State private var reminderTime = Date()

    var body: some View {
        List {
            Section {
                DatePicker(
                    "Reminder Time",
                    selection: $reminderTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
            } footer: {
                Text("We'll remind you to complete your daily lesson at this time.")
                    .font(.cpCaption)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Daily Reminder")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            reminderTime = appState.dataManager.currentUser?.reminderTime ?? Date()
        }
        .onChange(of: reminderTime) { _, newValue in
            appState.dataManager.setReminderTime(newValue)
        }
    }
}

// MARK: - Streak Shield Settings View
struct StreakShieldSettingsView: View {
    @Environment(AppStateController.self) private var appState
    @State private var shieldsEnabled = true

    var body: some View {
        List {
            Section {
                Toggle("Use Streak Shields", isOn: $shieldsEnabled)
                    .tint(Color.blue)
            } footer: {
                Text("When enabled, Streak Shields will automatically protect your streak if you miss a day. You earn 1 shield every 10 days (max 2).")
                    .font(.cpCaption)
            }

            Section {
                HStack {
                    Text("Available Shields")
                        .foregroundStyle(Color.cpLabel)
                    Spacer()
                    HStack(spacing: CPSpacing.xxs) {
                        ForEach(0..<Streak.maxShields, id: \.self) { index in
                            Image(systemName: "shield.fill")
                                .foregroundStyle(index < appState.dataManager.streak.streakShields ? Color.cpStreakShield : Color.cpSecondaryLabel.opacity(0.3))
                        }
                    }
                }
            } header: {
                Text("Current Status")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Streak Shields")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Data Privacy View
struct DataPrivacyView: View {
    @Environment(AppStateController.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirmation = false
    @State private var showingExportAlert = false

    var body: some View {
        List {
            Section {
                Button {
                    showingExportAlert = true
                } label: {
                    HStack {
                        SettingsRow(icon: "square.and.arrow.up", title: "Export My Data", color: .blue)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(Color.cpTertiaryLabel)
                    }
                }
            } footer: {
                Text("Download a copy of all your data including progress, scores, and settings.")
                    .font(.cpCaption)
            }

            Section {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    HStack {
                        SettingsRow(icon: "trash.fill", title: "Delete Account", color: .red)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(Color.cpTertiaryLabel)
                    }
                }
            } footer: {
                Text("Permanently delete your account and all associated data. This cannot be undone.")
                    .font(.cpCaption)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Data & Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Export Data", isPresented: $showingExportAlert) {
            Button("OK") {}
        } message: {
            Text("Data export will be available in a future update. Your data is stored securely on your device.")
        }
        .confirmationDialog(
            "Delete Account",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Account", role: .destructive) {
                deleteAccount()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete your account and all your data. You'll lose your progress, streak, and badges. This cannot be undone.")
        }
    }

    private func deleteAccount() {
        appState.dataManager.resetAllData()
        appState.logout()
        dismiss()
    }
}

// MARK: - How We Make Money View
struct HowWeMakeMoneyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CPSpacing.xl) {
                // Header
                VStack(alignment: .leading, spacing: CPSpacing.sm) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.green)

                    Text("Our Business Model")
                        .font(.cpTitle2)
                        .foregroundStyle(Color.cpLabel)
                }

                // Main Statement
                VStack(alignment: .leading, spacing: CPSpacing.md) {
                    TransparencyItem(
                        icon: "checkmark.circle.fill",
                        title: "Subscriptions Only",
                        description: "We make money from Pro subscriptions. That's it.",
                        isPositive: true
                    )

                    TransparencyItem(
                        icon: "xmark.circle.fill",
                        title: "No Bank or Broker Money",
                        description: "We don't receive payments from financial institutions to promote their products.",
                        isPositive: false
                    )

                    TransparencyItem(
                        icon: "xmark.circle.fill",
                        title: "No Affiliate Links",
                        description: "We don't earn commissions when you open accounts or buy financial products.",
                        isPositive: false
                    )

                    TransparencyItem(
                        icon: "xmark.circle.fill",
                        title: "No Ads",
                        description: "We don't sell your attention to advertisers.",
                        isPositive: false
                    )
                }

                // Why This Matters
                VStack(alignment: .leading, spacing: CPSpacing.sm) {
                    Text("Why This Matters")
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    Text("Many financial education companies are paid by banks and brokers to recommend their products. Our subscription model means we only answer to you, our learners.")
                        .font(.cpBody)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }
            }
            .padding(CPSpacing.md)
        }
        .background(Color.cpBackground)
        .navigationTitle("How We Make Money")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Transparency Item
struct TransparencyItem: View {
    let icon: String
    let title: String
    let description: String
    let isPositive: Bool

    var body: some View {
        HStack(alignment: .top, spacing: CPSpacing.md) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(isPositive ? Color.cpSuccess : Color.cpError)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                Text(title)
                    .font(.cpHeadline)
                    .foregroundStyle(Color.cpLabel)

                Text(description)
                    .font(.cpBody)
                    .foregroundStyle(Color.cpSecondaryLabel)
            }
        }
        .padding(CPSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
    }
}

// MARK: - Content Standards View
struct ContentStandardsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CPSpacing.xl) {
                // Sourcing Policy
                StandardsSection(
                    title: "Sourcing Policy",
                    items: [
                        "All financial concepts cite primary sources",
                        "Government sources preferred (IRS, SEC, CFPB)",
                        "Academic research from peer-reviewed journals",
                        "Industry data from reputable institutions"
                    ]
                )

                // Reviewer Credentials
                StandardsSection(
                    title: "Reviewer Credentials",
                    items: [
                        "Content reviewed by CFP® professionals",
                        "Tax content reviewed by CPAs/EAs",
                        "Investment content reviewed by CFA® charterholders",
                        "All reviewers disclosed per lesson"
                    ]
                )

                // Corrections Policy
                VStack(alignment: .leading, spacing: CPSpacing.sm) {
                    Text("Corrections Policy")
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    Text("We maintain a public corrections log. If we make an error, we correct it promptly and transparently.")
                        .font(.cpBody)
                        .foregroundStyle(Color.cpSecondaryLabel)

                    Button {
                        // In real app, open corrections log
                    } label: {
                        Text("View Corrections Log")
                            .font(.cpCallout)
                            .foregroundStyle(Color.blue)
                    }
                }
                .padding(CPSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cpSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))

                // Report Issue
                VStack(alignment: .leading, spacing: CPSpacing.sm) {
                    Text("Found an Error?")
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    Text("If you find inaccurate information, please let us know. We take content accuracy seriously.")
                        .font(.cpBody)
                        .foregroundStyle(Color.cpSecondaryLabel)

                    Button {
                        // In real app, open feedback form
                    } label: {
                        HStack {
                            Image(systemName: "exclamationmark.bubble.fill")
                            Text("Report an Issue")
                        }
                    }
                    .cpSecondaryButton()
                }
                .padding(CPSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cpSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
            }
            .padding(CPSpacing.md)
        }
        .background(Color.cpBackground)
        .navigationTitle("Content Standards")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Standards Section
struct StandardsSection: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.sm) {
            Text(title)
                .font(.cpHeadline)
                .foregroundStyle(Color.cpLabel)

            VStack(alignment: .leading, spacing: CPSpacing.xs) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: CPSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.cpSuccess)

                        Text(item)
                            .font(.cpBody)
                            .foregroundStyle(Color.cpSecondaryLabel)
                    }
                }
            }
        }
        .padding(CPSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
    }
}

#Preview {
    SettingsView()
        .environment(AppStateController())
}
