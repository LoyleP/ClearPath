import SwiftUI

// MARK: - Main Tab View
/// Primary navigation structure after authentication
struct MainTabView: View {
    @Environment(AppStateController.self) private var appState
    @State private var selectedTab: Tab = .home

    enum Tab: Hashable {
        case home
        case learn
        case leagues
        case moneyLab
        case profile
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)

            LearnTab()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
                .tag(Tab.learn)

            LeaguesView()
                .tabItem {
                    Label("Leagues", systemImage: "trophy.fill")
                }
                .tag(Tab.leagues)

            MoneyLabTab()
                .tabItem {
                    Label("Lab", systemImage: "flask.fill")
                }
                .tag(Tab.moneyLab)

            ProfileTab()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(Tab.profile)
        }
    }
}

// MARK: - Home Tab
struct HomeTab: View {
    @Environment(AppStateController.self) private var appState
    @State private var showingLesson = false
    @State private var showingStreakDetail = false
    @State private var showingMoneyScore = false
    @State private var showingReview = false
    @State private var showingPaywall = false

    private var dataManager: AppDataManager {
        appState.dataManager
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CPSpacing.md) {
                    // Greeting
                    GreetingHeader(name: dataManager.currentUser?.displayName ?? "Friend")

                    // Streak Card
                    StreakCard(
                        currentStreak: dataManager.streak.currentStreak,
                        bestStreak: dataManager.streak.bestStreak,
                        action: { showingStreakDetail = true }
                    )

                    // Money Score Card
                    MoneyScoreCard(
                        score: dataManager.moneyScore.scoreInt,
                        delta: dataManager.moneyScore.weeklyDeltaFormatted,
                        action: { showingMoneyScore = true }
                    )

                    // Today's Lesson Card
                    if let lesson = dataManager.nextLesson {
                        LessonCard(
                            title: lesson.title,
                            subtitle: lesson.description,
                            estimatedMinutes: lesson.estimatedMinutes,
                            isCompleted: dataManager.userProgress.hasCompletedDailyLesson,
                            action: {
                                if dataManager.canStartNewLesson {
                                    showingLesson = true
                                } else if appState.canShowPaywall {
                                    showingPaywall = true
                                }
                            }
                        )
                    }

                    // Review Card (if concepts are fading)
                    if !dataManager.fadingConcepts.isEmpty {
                        ReviewCard(
                            conceptCount: dataManager.fadingConcepts.count,
                            action: { showingReview = true }
                        )
                    }

                    // Money Lab Card
                    MoneyLabHomeCard(action: {
                        // Navigate to Money Lab tab
                    })
                }
                .padding(.horizontal, CPSpacing.md)
                .padding(.top, CPSpacing.sm)
            }
            .background(Color.cpBackground)
            .navigationTitle("ClearPath")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingLesson) {
                if let lesson = dataManager.nextLesson {
                    LessonView(lesson: lesson)
                }
            }
            .sheet(isPresented: $showingStreakDetail) {
                StreakDetailView()
            }
            .sheet(isPresented: $showingMoneyScore) {
                MoneyScoreView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}

// MARK: - Greeting Header
struct GreetingHeader: View {
    let name: String

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                Text("\(greeting),")
                    .font(.cpCallout)
                    .foregroundStyle(Color.cpSecondaryLabel)

                Text(name)
                    .font(.cpTitle2)
                    .foregroundStyle(Color.cpLabel)
            }
            Spacer()
        }
        .padding(.bottom, CPSpacing.sm)
    }
}

// MARK: - Money Lab Home Card
struct MoneyLabHomeCard: View {
    let action: () -> Void

    var body: some View {
        CPTappableCard(action: action) {
            HStack(spacing: CPSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: CPCornerRadius.sm)
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: "flask.fill")
                        .font(.title2)
                        .foregroundStyle(Color.purple)
                }

                VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                    Text("Money Lab")
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    Text("Try simulators with your numbers")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpTertiaryLabel)
            }
        }
    }
}

// MARK: - Learn Tab
struct LearnTab: View {
    @Environment(AppStateController.self) private var appState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CPSpacing.md) {
                    ForEach(appState.dataManager.tracks) { track in
                        TrackCard(track: track, progress: appState.dataManager.userProgress)
                    }
                }
                .padding(.horizontal, CPSpacing.md)
                .padding(.top, CPSpacing.sm)
            }
            .background(Color.cpBackground)
            .navigationTitle("Learn")
        }
    }
}

// MARK: - Track Card
struct TrackCard: View {
    let track: Track
    let progress: UserProgress

    var body: some View {
        NavigationLink {
            TrackDetailView(track: track)
        } label: {
            HStack(spacing: CPSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: CPCornerRadius.sm)
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: track.icon)
                        .font(.title2)
                        .foregroundStyle(Color.blue)
                }

                VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                    Text(track.name)
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    Text("\(track.completedLessons(for: progress))/\(track.totalLessons) lessons")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }

                Spacer()

                CPCircularProgress(
                    progress: track.progressPercentage(for: progress),
                    lineWidth: 4,
                    size: 40
                )
            }
            .padding(CPSpacing.md)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.lg))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Money Lab Tab
struct MoneyLabTab: View {
    @Environment(AppStateController.self) private var appState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CPSpacing.md) {
                    ForEach(MoneyLabSimulator.allCases) { simulator in
                        MoneyLabSimulatorCard(simulator: simulator)
                    }
                }
                .padding(.horizontal, CPSpacing.md)
                .padding(.top, CPSpacing.sm)
            }
            .background(Color.cpBackground)
            .navigationTitle("Money Lab")
        }
    }
}

// MARK: - Money Lab Simulator Card
struct MoneyLabSimulatorCard: View {
    let simulator: MoneyLabSimulator
    @Environment(AppStateController.self) private var appState
    @State private var showingSimulator = false
    @State private var showingPaywall = false

    var body: some View {
        Button {
            if appState.dataManager.canRunMoneyLab() {
                showingSimulator = true
            } else if appState.canShowPaywall {
                showingPaywall = true
            }
        } label: {
            HStack(spacing: CPSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: CPCornerRadius.sm)
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: simulator.icon)
                        .font(.title2)
                        .foregroundStyle(Color.purple)
                }

                VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                    Text(simulator.rawValue)
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    Text(simulator.description)
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpTertiaryLabel)
            }
            .padding(CPSpacing.md)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.lg))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingSimulator) {
            SimulatorView(simulator: simulator)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
}

// MARK: - Profile Tab
struct ProfileTab: View {
    @Environment(AppStateController.self) private var appState
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CPSpacing.xl) {
                    // Profile Header
                    ProfileHeader()

                    // Stats
                    StatsSection()

                    // Badges
                    BadgesSection()
                }
                .padding(.horizontal, CPSpacing.md)
                .padding(.top, CPSpacing.sm)
            }
            .background(Color.cpBackground)
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(Color.cpSecondaryLabel)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
}

// MARK: - Profile Header
struct ProfileHeader: View {
    @Environment(AppStateController.self) private var appState

    var body: some View {
        VStack(spacing: CPSpacing.md) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient.cpPrimaryGradient)
                    .frame(width: 100, height: 100)

                Text(appState.dataManager.currentUser?.displayName.prefix(1).uppercased() ?? "?")
                    .font(.cpDisplayMedium)
                    .foregroundStyle(.white)
            }

            // Name
            Text(appState.dataManager.currentUser?.displayName ?? "User")
                .font(.cpTitle2)
                .foregroundStyle(Color.cpLabel)

            // Subscription status
            if appState.dataManager.hasProAccess {
                HStack(spacing: CPSpacing.xxs) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.yellow)
                    Text("Pro Member")
                        .font(.cpCalloutBold)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }
            }
        }
    }
}

// MARK: - Stats Section
struct StatsSection: View {
    @Environment(AppStateController.self) private var appState

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.sm) {
            Text("Your Stats")
                .font(.cpHeadline)
                .foregroundStyle(Color.cpLabel)

            HStack(spacing: CPSpacing.md) {
                StatItem(
                    value: "\(appState.dataManager.moneyScore.scoreInt)",
                    label: "Money Score",
                    icon: "chart.bar.fill"
                )

                StatItem(
                    value: "\(appState.dataManager.streak.currentStreak)",
                    label: "Day Streak",
                    icon: "flame.fill"
                )

                StatItem(
                    value: "\(appState.dataManager.userProgress.completedLessonIDs.count)",
                    label: "Lessons",
                    icon: "book.fill"
                )
            }
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: CPSpacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.blue)

            Text(value)
                .font(.cpTitle2)
                .foregroundStyle(Color.cpLabel)

            Text(label)
                .font(.cpCaption)
                .foregroundStyle(Color.cpSecondaryLabel)
        }
        .frame(maxWidth: .infinity)
        .padding(CPSpacing.md)
        .background(Color.cpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
    }
}

// MARK: - Badges Section
struct BadgesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.sm) {
            Text("Badges")
                .font(.cpHeadline)
                .foregroundStyle(Color.cpLabel)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CPSpacing.md) {
                    ForEach(StreakMilestone.all) { milestone in
                        BadgeItem(milestone: milestone, isEarned: false)
                    }
                }
            }
        }
    }
}

// MARK: - Badge Item
struct BadgeItem: View {
    let milestone: StreakMilestone
    let isEarned: Bool

    var body: some View {
        VStack(spacing: CPSpacing.xs) {
            ZStack {
                Circle()
                    .fill(isEarned ? Color.yellow.opacity(0.2) : Color.cpSecondaryBackground)
                    .frame(width: 60, height: 60)

                Image(systemName: milestone.icon)
                    .font(.title2)
                    .foregroundStyle(isEarned ? Color.yellow : Color.cpTertiaryLabel)
            }

            Text(milestone.title)
                .font(.cpCaption)
                .foregroundStyle(isEarned ? Color.cpLabel : Color.cpTertiaryLabel)
                .multilineTextAlignment(.center)
        }
        .frame(width: 80)
    }
}

#Preview {
    MainTabView()
        .environment(AppStateController())
}