import SwiftUI

// MARK: - Streak Detail View
struct StreakDetailView: View {
    @Environment(AppStateController.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var showingMilestone = false
    @State private var achievedMilestone: StreakMilestone?

    private var streak: Streak {
        appState.dataManager.streak
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CPSpacing.xl) {
                    // Main Streak Display
                    StreakHeroSection(streak: streak)

                    // Streak Shields
                    StreakShieldsSection(shields: streak.streakShields)

                    // Calendar
                    StreakCalendarSection(streak: streak)

                    // Friends' Streaks
                    FriendsStreaksSection(friends: appState.dataManager.friends)

                    // Streak Rules Info
                    StreakRulesSection()
                }
                .padding(.horizontal, CPSpacing.md)
                .padding(.top, CPSpacing.md)
            }
            .background(Color.cpBackground)
            .navigationTitle("Your Streak")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingMilestone) {
            if let milestone = achievedMilestone {
                MilestoneCelebrationView(milestone: milestone)
            }
        }
        .onAppear {
            checkForMilestone()
        }
    }

    private func checkForMilestone() {
        if streak.isAtMilestone {
            achievedMilestone = StreakMilestone.all.first { $0.days == streak.currentStreak }
            showingMilestone = achievedMilestone != nil
        }
    }
}

// MARK: - Streak Hero Section
struct StreakHeroSection: View {
    let streak: Streak

    var body: some View {
        VStack(spacing: CPSpacing.md) {
            // Flame Icon with Streak Count
            ZStack {
                Circle()
                    .fill(LinearGradient.cpStreakGradient.opacity(0.2))
                    .frame(width: 140, height: 140)

                VStack(spacing: CPSpacing.xxs) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(LinearGradient.cpStreakGradient)

                    Text("\(streak.currentStreak)")
                        .font(.cpDisplayMedium)
                        .foregroundStyle(Color.cpLabel)
                }
            }

            Text("\(streak.currentStreak) day streak!")
                .font(.cpTitle2)
                .foregroundStyle(Color.cpLabel)

            HStack(spacing: CPSpacing.xl) {
                VStack(spacing: CPSpacing.xxs) {
                    Text("Current")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                    Text("\(streak.currentStreak)")
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)
                }

                Divider()
                    .frame(height: 30)

                VStack(spacing: CPSpacing.xxs) {
                    Text("Best")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                    Text("\(streak.bestStreak)")
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)
                }
            }
            .padding(CPSpacing.md)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
        }
    }
}

// MARK: - Streak Shields Section
struct StreakShieldsSection: View {
    let shields: Int

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.sm) {
            Text("Streak Shields")
                .font(.cpHeadline)
                .foregroundStyle(Color.cpLabel)

            HStack(spacing: CPSpacing.md) {
                // Shield Icons
                HStack(spacing: CPSpacing.xs) {
                    ForEach(0..<Streak.maxShields, id: \.self) { index in
                        Image(systemName: "shield.fill")
                            .font(.title)
                            .foregroundStyle(index < shields ? Color.cpStreakShield : Color.cpSecondaryLabel.opacity(0.3))
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: CPSpacing.xxs) {
                    Text("\(shields)/\(Streak.maxShields)")
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    Text("shields available")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }
            }
            .padding(CPSpacing.md)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))

            Text("Earn 1 shield every 10 days. Shields protect your streak automatically.")
                .font(.cpCaption)
                .foregroundStyle(Color.cpTertiaryLabel)
        }
    }
}

// MARK: - Streak Calendar Section
struct StreakCalendarSection: View {
    let streak: Streak
    @State private var displayMonth = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.sm) {
            Text("Activity")
                .font(.cpHeadline)
                .foregroundStyle(Color.cpLabel)

            SimpleCalendarView(
                month: displayMonth,
                activityCalendar: streak.activityCalendar
            )
            .padding(CPSpacing.md)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))

            // Legend
            HStack(spacing: CPSpacing.lg) {
                LegendItem(color: .cpSuccess, label: "Completed")
                LegendItem(color: .cpStreakShield, label: "Shielded")
                LegendItem(color: .cpWarning, label: "Repaired")
            }
            .font(.cpCaption)
        }
    }
}

// MARK: - Simple Calendar View
struct SimpleCalendarView: View {
    let month: Date
    let activityCalendar: [Date: DayStatus]

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    private var daysInMonth: [Date?] {
        let range = calendar.range(of: .day, in: .month, for: month)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)

        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }

        return days
    }

    var body: some View {
        VStack(spacing: CPSpacing.sm) {
            // Weekday headers
            HStack {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                        .frame(maxWidth: .infinity)
                }
            }

            // Days grid
            LazyVGrid(columns: columns, spacing: CPSpacing.xs) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        CalendarDayView(
                            date: date,
                            status: activityCalendar[calendar.startOfDay(for: date)]
                        )
                    } else {
                        Color.clear
                            .frame(width: 32, height: 32)
                    }
                }
            }
        }
    }
}

// MARK: - Calendar Day View
struct CalendarDayView: View {
    let date: Date
    let status: DayStatus?

    private var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }

    private var backgroundColor: Color {
        guard let status = status else { return .clear }
        switch status {
        case .completed: return .cpSuccess
        case .shielded: return .cpStreakShield
        case .repaired: return .cpWarning
        case .missed: return .clear
        }
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor.opacity(status != nil ? 1 : 0))
                .frame(width: 32, height: 32)

            Text("\(dayNumber)")
                .font(.cpCaption)
                .foregroundStyle(status != nil ? .white : Color.cpLabel)
        }
    }
}

// MARK: - Legend Item
struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: CPSpacing.xxs) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .foregroundStyle(Color.cpSecondaryLabel)
        }
    }
}

// MARK: - Friends Streaks Section
struct FriendsStreaksSection: View {
    let friends: [Friend]

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.sm) {
            Text("Friends' Streaks")
                .font(.cpHeadline)
                .foregroundStyle(Color.cpLabel)

            VStack(spacing: CPSpacing.xs) {
                ForEach(friends) { friend in
                    FriendStreakRow(friend: friend)
                }
            }
        }
    }
}

// MARK: - Friend Streak Row
struct FriendStreakRow: View {
    let friend: Friend

    var body: some View {
        HStack(spacing: CPSpacing.md) {
            // Avatar
            Circle()
                .fill(LinearGradient.cpPrimaryGradient)
                .frame(width: 36, height: 36)
                .overlay(
                    Text(friend.displayName.prefix(1).uppercased())
                        .font(.cpCaption)
                        .foregroundStyle(.white)
                )

            Text(friend.displayName)
                .font(.cpBody)
                .foregroundStyle(Color.cpLabel)

            Spacer()

            HStack(spacing: CPSpacing.xxs) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(Color.cpStreakActive)
                Text("\(friend.currentStreak)")
                    .font(.cpBodyBold)
                    .foregroundStyle(Color.cpLabel)
            }
        }
        .padding(CPSpacing.sm)
        .background(Color.cpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.sm))
    }
}

// MARK: - Streak Rules Section
struct StreakRulesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.sm) {
            Text("How Streaks Work")
                .font(.cpHeadline)
                .foregroundStyle(Color.cpLabel)

            VStack(alignment: .leading, spacing: CPSpacing.xs) {
                RuleRow(icon: "checkmark.circle", text: "Complete a lesson or review each day")
                RuleRow(icon: "shield.fill", text: "Earn shields every 10 days (max 2)")
                RuleRow(icon: "arrow.clockwise", text: "Repair once per 30 days if you miss")
            }
            .padding(CPSpacing.md)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
        }
    }
}

// MARK: - Rule Row
struct RuleRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: CPSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(Color.cpSecondaryLabel)
                .frame(width: 24)

            Text(text)
                .font(.cpBody)
                .foregroundStyle(Color.cpSecondaryLabel)
        }
    }
}

// MARK: - Milestone Celebration View
struct MilestoneCelebrationView: View {
    let milestone: StreakMilestone
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: CPSpacing.xxl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: 160, height: 160)

                Image(systemName: milestone.icon)
                    .font(.system(size: 70))
                    .foregroundStyle(Color.yellow)
            }

            VStack(spacing: CPSpacing.md) {
                Text("\(milestone.days) Day Streak!")
                    .font(.cpTitle)
                    .foregroundStyle(Color.cpLabel)

                Text(milestone.title)
                    .font(.cpTitle2)
                    .foregroundStyle(Color.yellow)

                Text("You've earned a new badge")
                    .font(.cpBody)
                    .foregroundStyle(Color.cpSecondaryLabel)
            }

            Spacer()

            Button("Continue") {
                dismiss()
            }
            .cpPrimaryButton()
            .padding(.horizontal, CPSpacing.xl)
            .padding(.bottom, CPSpacing.xxl)
        }
        .background(Color.cpBackground)
    }
}

#Preview {
    StreakDetailView()
        .environment(AppStateController())
}
