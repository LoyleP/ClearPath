import SwiftUI

// MARK: - Leagues View
struct LeaguesView: View {
    @Environment(AppStateController.self) private var appState
    @State private var selectedTab: LeagueTab = .friends
    @State private var showingInviteSheet = false
    @State private var showingPublicProfile: Friend?

    private var isLeaguesUnlocked: Bool {
        // Leagues unlock after 10 completed lessons (post-launch feature)
        appState.dataManager.userProgress.completedLessonIDs.count >= 10
    }

    private var isLeaguesActive: Bool {
        // In real app, this would check DAU >= 2,000
        // For MVP, always false to show "Coming Soon"
        false
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Tab", selection: $selectedTab) {
                    ForEach(LeagueTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, CPSpacing.md)
                .padding(.top, CPSpacing.md)

                // Content
                TabView(selection: $selectedTab) {
                    RankingsTab(
                        isUnlocked: isLeaguesUnlocked,
                        isActive: isLeaguesActive,
                        league: appState.dataManager.currentLeague,
                        onTapMember: { member in
                            // Convert to friend for public profile
                            let friend = Friend(
                                id: member.id,
                                userID: member.userID,
                                displayName: member.displayName,
                                currentStreak: 0,
                                totalScore: member.weeklyXP,
                                badgeCount: 0
                            )
                            showingPublicProfile = friend
                        }
                    )
                    .tag(LeagueTab.rankings)

                    FriendsTab(
                        friends: appState.dataManager.friends,
                        onInvite: { showingInviteSheet = true },
                        onTapFriend: { friend in
                            showingPublicProfile = friend
                        }
                    )
                    .tag(LeagueTab.friends)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .background(Color.cpBackground)
            .navigationTitle("Leagues")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingInviteSheet) {
                ShareInviteSheet()
            }
            .sheet(item: $showingPublicProfile) { friend in
                PublicProfileView(friend: friend)
            }
        }
    }
}

// MARK: - League Tab
enum LeagueTab: String, CaseIterable, Identifiable {
    case rankings = "Rankings"
    case friends = "Friends"

    var id: String { rawValue }
}

// MARK: - Rankings Tab
struct RankingsTab: View {
    let isUnlocked: Bool
    let isActive: Bool
    let league: League?
    let onTapMember: (LeagueMember) -> Void

    var body: some View {
        ScrollView {
            if !isUnlocked {
                // Not enough lessons completed
                LeaguesLockedView(
                    lessonsNeeded: 10,
                    lessonsCompleted: 0
                )
            } else if !isActive {
                // Leagues feature not yet active (DAU < 2,000)
                LeaguesComingSoonView()
            } else if let league = league {
                // Full league view
                VStack(spacing: CPSpacing.lg) {
                    // Current Tier
                    LeagueTierHeader(tier: league.tier)

                    // Time Remaining
                    TimeRemainingCard(endDate: league.weekEndDate)

                    // Rankings List
                    RankingsList(
                        members: league.members,
                        currentUserRank: league.currentUserRank,
                        onTapMember: onTapMember
                    )
                }
                .padding(CPSpacing.md)
            }
        }
        .background(Color.cpBackground)
    }
}

// MARK: - Leagues Locked View
struct LeaguesLockedView: View {
    let lessonsNeeded: Int
    let lessonsCompleted: Int

    var body: some View {
        VStack(spacing: CPSpacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.cpSecondaryBackground)
                    .frame(width: 120, height: 120)

                Image(systemName: "lock.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.cpSecondaryLabel)
            }

            VStack(spacing: CPSpacing.sm) {
                Text("Leagues Locked")
                    .font(.cpTitle2)
                    .foregroundStyle(Color.cpLabel)

                Text("Complete \(lessonsNeeded) lessons to unlock leagues")
                    .font(.cpBody)
                    .foregroundStyle(Color.cpSecondaryLabel)
                    .multilineTextAlignment(.center)

                // Progress
                HStack(spacing: CPSpacing.xs) {
                    Text("\(lessonsCompleted)")
                        .font(.cpHeadline)
                        .foregroundStyle(Color.blue)
                    Text("of \(lessonsNeeded) lessons completed")
                        .font(.cpBody)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }
                .padding(.top, CPSpacing.sm)
            }

            Spacer()
        }
        .padding(CPSpacing.xl)
    }
}

// MARK: - Leagues Coming Soon View
struct LeaguesComingSoonView: View {
    var body: some View {
        VStack(spacing: CPSpacing.xl) {
            Spacer()

            ZStack {
                Circle()
                    .fill(LinearGradient.cpPrimaryGradient.opacity(0.2))
                    .frame(width: 120, height: 120)

                Image(systemName: "trophy.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(LinearGradient.cpPrimaryGradient)
            }

            VStack(spacing: CPSpacing.sm) {
                Text("Leagues Coming Soon")
                    .font(.cpTitle2)
                    .foregroundStyle(Color.cpLabel)

                Text("Weekly competitions with other learners. Earn XP, climb the ranks, and get promoted!")
                    .font(.cpBody)
                    .foregroundStyle(Color.cpSecondaryLabel)
                    .multilineTextAlignment(.center)

                // Tier Preview
                HStack(spacing: CPSpacing.sm) {
                    ForEach(LeagueTier.allCases, id: \.self) { tier in
                        VStack(spacing: CPSpacing.xxs) {
                            Image(systemName: tier.icon)
                                .font(.title2)
                                .foregroundStyle(tier.color)
                            Text(tier.rawValue)
                                .font(.cpCaption)
                                .foregroundStyle(Color.cpSecondaryLabel)
                        }
                    }
                }
                .padding(.top, CPSpacing.lg)
            }

            Spacer()
        }
        .padding(CPSpacing.xl)
    }
}

// MARK: - League Tier Header
struct LeagueTierHeader: View {
    let tier: LeagueTier

    var body: some View {
        VStack(spacing: CPSpacing.md) {
            ZStack {
                Circle()
                    .fill(tier.color.opacity(0.2))
                    .frame(width: 100, height: 100)

                Image(systemName: tier.icon)
                    .font(.system(size: 50))
                    .foregroundStyle(tier.color)
            }

            Text("\(tier.rawValue) League")
                .font(.cpTitle2)
                .foregroundStyle(Color.cpLabel)
        }
    }
}

// MARK: - Time Remaining Card
struct TimeRemainingCard: View {
    let endDate: Date

    private var timeRemaining: String {
        let interval = endDate.timeIntervalSinceNow
        let days = Int(interval / 86400)
        let hours = Int((interval.truncatingRemainder(dividingBy: 86400)) / 3600)

        if days > 0 {
            return "\(days)d \(hours)h"
        } else {
            return "\(hours)h remaining"
        }
    }

    var body: some View {
        HStack {
            Image(systemName: "clock.fill")
                .foregroundStyle(Color.cpSecondaryLabel)

            Text("Week ends in \(timeRemaining)")
                .font(.cpBody)
                .foregroundStyle(Color.cpSecondaryLabel)

            Spacer()
        }
        .padding(CPSpacing.md)
        .background(Color.cpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
    }
}

// MARK: - Rankings List
struct RankingsList: View {
    let members: [LeagueMember]
    let currentUserRank: Int
    let onTapMember: (LeagueMember) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: CPSpacing.sm) {
            // Promotion Zone
            Text("Promotion Zone")
                .font(.cpCaption)
                .foregroundStyle(Color.cpSuccess)
                .padding(.leading, CPSpacing.xs)

            ForEach(Array(members.prefix(10).enumerated()), id: \.element.id) { index, member in
                LeagueMemberRow(
                    rank: index + 1,
                    member: member,
                    isCurrentUser: index + 1 == currentUserRank,
                    zone: .promotion
                ) {
                    onTapMember(member)
                }
            }

            if members.count > 10 {
                Divider()
                    .padding(.vertical, CPSpacing.sm)

                // Safe Zone
                Text("Safe Zone")
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpSecondaryLabel)
                    .padding(.leading, CPSpacing.xs)

                let safeZoneMembers = Array(members.dropFirst(10).dropLast(5))
                ForEach(Array(safeZoneMembers.enumerated()), id: \.element.id) { index, member in
                    let rank = index + 11
                    LeagueMemberRow(
                        rank: rank,
                        member: member,
                        isCurrentUser: rank == currentUserRank,
                        zone: .safe
                    ) {
                        onTapMember(member)
                    }
                }

                Divider()
                    .padding(.vertical, CPSpacing.sm)

                // Demotion Zone
                Text("Demotion Zone")
                    .font(.cpCaption)
                    .foregroundStyle(Color.cpError)
                    .padding(.leading, CPSpacing.xs)

                let demotionZoneMembers = Array(members.suffix(5))
                let startIndex = members.count - 5
                ForEach(Array(demotionZoneMembers.enumerated()), id: \.element.id) { index, member in
                    let rank = startIndex + index + 1
                    LeagueMemberRow(
                        rank: rank,
                        member: member,
                        isCurrentUser: rank == currentUserRank,
                        zone: .demotion
                    ) {
                        onTapMember(member)
                    }
                }
            }
        }
    }
}

// MARK: - Ranking Zone
enum RankingZone {
    case promotion
    case safe
    case demotion

    var backgroundColor: Color {
        switch self {
        case .promotion: return .cpSuccess.opacity(0.1)
        case .safe: return .cpSecondaryBackground
        case .demotion: return .cpError.opacity(0.1)
        }
    }
}

// MARK: - League Member Row
struct LeagueMemberRow: View {
    let rank: Int
    let member: LeagueMember
    let isCurrentUser: Bool
    let zone: RankingZone
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CPSpacing.md) {
                // Rank
                Text("\(rank)")
                    .font(.cpHeadline)
                    .foregroundStyle(isCurrentUser ? Color.blue : Color.cpSecondaryLabel)
                    .frame(width: 30)

                // Avatar
                Circle()
                    .fill(isCurrentUser ? LinearGradient.cpPrimaryGradient : LinearGradient(colors: [.gray], startPoint: .top, endPoint: .bottom))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Text(member.displayName.prefix(1).uppercased())
                            .font(.cpCaption)
                            .foregroundStyle(.white)
                    )

                // Name
                Text(member.displayName)
                    .font(isCurrentUser ? .cpBodyBold : .cpBody)
                    .foregroundStyle(Color.cpLabel)

                if isCurrentUser {
                    Text("You")
                        .font(.cpCaption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, CPSpacing.xs)
                        .padding(.vertical, 2)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }

                Spacer()

                // XP
                Text("\(member.weeklyXP) XP")
                    .font(.cpBodyBold)
                    .foregroundStyle(Color.cpLabel)
            }
            .padding(CPSpacing.sm)
            .background(isCurrentUser ? Color.blue.opacity(0.1) : zone.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.sm))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Friends Tab
struct FriendsTab: View {
    let friends: [Friend]
    let onInvite: () -> Void
    let onTapFriend: (Friend) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: CPSpacing.lg) {
                // Invite Card
                InviteFriendsCard(onInvite: onInvite)

                // Friends List
                if friends.isEmpty {
                    EmptyFriendsView(onInvite: onInvite)
                } else {
                    VStack(alignment: .leading, spacing: CPSpacing.sm) {
                        Text("Friends (\(friends.count))")
                            .font(.cpHeadline)
                            .foregroundStyle(Color.cpLabel)

                        ForEach(friends) { friend in
                            FriendRow(friend: friend) {
                                onTapFriend(friend)
                            }
                        }
                    }
                }
            }
            .padding(CPSpacing.md)
        }
        .background(Color.cpBackground)
    }
}

// MARK: - Invite Friends Card
struct InviteFriendsCard: View {
    let onInvite: () -> Void

    var body: some View {
        VStack(spacing: CPSpacing.md) {
            HStack(spacing: CPSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.cpSuccess.opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: "gift.fill")
                        .font(.title2)
                        .foregroundStyle(Color.cpSuccess)
                }

                VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                    Text("Invite Friends, Get Pro")
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    Text("Both you and your friend get 1 month Pro free!")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }

                Spacer()
            }

            Button(action: onInvite) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Invite Link")
                }
            }
            .cpPrimaryButton()
        }
        .padding(CPSpacing.md)
        .background(Color.cpSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
    }
}

// MARK: - Empty Friends View
struct EmptyFriendsView: View {
    let onInvite: () -> Void

    var body: some View {
        VStack(spacing: CPSpacing.lg) {
            Image(systemName: "person.2.fill")
                .font(.system(size: 50))
                .foregroundStyle(Color.cpSecondaryLabel)

            VStack(spacing: CPSpacing.sm) {
                Text("No Friends Yet")
                    .font(.cpHeadline)
                    .foregroundStyle(Color.cpLabel)

                Text("Invite friends to learn together and track each other's progress")
                    .font(.cpBody)
                    .foregroundStyle(Color.cpSecondaryLabel)
                    .multilineTextAlignment(.center)
            }

            Button("Invite Friends", action: onInvite)
                .cpSecondaryButton()
        }
        .padding(CPSpacing.xxl)
    }
}

// MARK: - Friend Row
struct FriendRow: View {
    let friend: Friend
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: CPSpacing.md) {
                // Avatar
                Circle()
                    .fill(LinearGradient.cpPrimaryGradient)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(friend.displayName.prefix(1).uppercased())
                            .font(.cpBody)
                            .foregroundStyle(.white)
                    )

                // Info
                VStack(alignment: .leading, spacing: CPSpacing.xxs) {
                    Text(friend.displayName)
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)

                    HStack(spacing: CPSpacing.xs) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(Color.cpStreakActive)
                        Text("\(friend.currentStreak) day streak")
                            .font(.cpCaption)
                            .foregroundStyle(Color.cpSecondaryLabel)
                    }
                }

                Spacer()

                // Score
                VStack(alignment: .trailing, spacing: CPSpacing.xxs) {
                    Text("\(friend.totalScore)")
                        .font(.cpHeadline)
                        .foregroundStyle(Color.cpLabel)
                    Text("score")
                        .font(.cpCaption)
                        .foregroundStyle(Color.cpSecondaryLabel)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.cpTertiaryLabel)
            }
            .padding(CPSpacing.md)
            .background(Color.cpSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Share Invite Sheet
struct ShareInviteSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false

    private let inviteLink = "https://clearpath.app/invite/USER123"
    private let inviteMessage = "Join me on ClearPath! We'll both get 1 month of Pro free when you sign up."

    var body: some View {
        NavigationStack {
            VStack(spacing: CPSpacing.xl) {
                Spacer()

                // Gift Icon
                ZStack {
                    Circle()
                        .fill(Color.cpSuccess.opacity(0.2))
                        .frame(width: 120, height: 120)

                    Image(systemName: "gift.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.cpSuccess)
                }

                // Info
                VStack(spacing: CPSpacing.md) {
                    Text("Share & Earn")
                        .font(.cpTitle)
                        .foregroundStyle(Color.cpLabel)

                    Text("When your friend joins ClearPath, you both get 1 month of Pro free!")
                        .font(.cpBody)
                        .foregroundStyle(Color.cpSecondaryLabel)
                        .multilineTextAlignment(.center)
                }

                // Rewards Breakdown
                VStack(spacing: CPSpacing.sm) {
                    RewardRow(icon: "person.fill", text: "You get 1 month Pro")
                    RewardRow(icon: "person.fill.badge.plus", text: "Friend gets 1 month Pro")
                }
                .padding(CPSpacing.md)
                .background(Color.cpSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
                .padding(.horizontal, CPSpacing.md)

                Spacer()

                // Share Button
                Button {
                    showingShareSheet = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Invite Link")
                    }
                }
                .cpPrimaryButton()
                .padding(.horizontal, CPSpacing.md)
                .padding(.bottom, CPSpacing.xl)
            }
            .padding(.horizontal, CPSpacing.md)
            .navigationTitle("Invite Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [inviteMessage, inviteLink])
            }
        }
    }
}

// MARK: - Reward Row
struct RewardRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: CPSpacing.md) {
            Image(systemName: icon)
                .foregroundStyle(Color.cpSuccess)
                .frame(width: 24)

            Text(text)
                .font(.cpBody)
                .foregroundStyle(Color.cpLabel)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.cpSuccess)
        }
    }
}

// MARK: - Share Sheet (UIKit Wrapper)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Public Profile View
struct PublicProfileView: View {
    @Environment(\.dismiss) private var dismiss
    let friend: Friend

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CPSpacing.xl) {
                    // Avatar
                    Circle()
                        .fill(LinearGradient.cpPrimaryGradient)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(friend.displayName.prefix(1).uppercased())
                                .font(.cpTitle)
                                .foregroundStyle(.white)
                        )

                    // Name
                    Text(friend.displayName)
                        .font(.cpTitle2)
                        .foregroundStyle(Color.cpLabel)

                    // Stats
                    HStack(spacing: CPSpacing.xl) {
                        ProfileStatItem(value: "\(friend.totalScore)", label: "Score")
                        ProfileStatItem(value: "\(friend.currentStreak)", label: "Streak")
                        ProfileStatItem(value: "\(friend.badgeCount)", label: "Badges")
                    }
                    .padding(CPSpacing.lg)
                    .background(Color.cpSecondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))

                    // Badges Section (placeholder)
                    VStack(alignment: .leading, spacing: CPSpacing.sm) {
                        Text("Recent Badges")
                            .font(.cpHeadline)
                            .foregroundStyle(Color.cpLabel)

                        if friend.badgeCount > 0 {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: CPSpacing.md) {
                                ForEach(0..<min(friend.badgeCount, 8), id: \.self) { _ in
                                    ZStack {
                                        Circle()
                                            .fill(Color.yellow.opacity(0.2))
                                            .frame(width: 60, height: 60)

                                        Image(systemName: "star.fill")
                                            .font(.title2)
                                            .foregroundStyle(Color.yellow)
                                    }
                                }
                            }
                        } else {
                            Text("No badges earned yet")
                                .font(.cpBody)
                                .foregroundStyle(Color.cpSecondaryLabel)
                        }
                    }
                    .padding(CPSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.cpSecondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))
                }
                .padding(CPSpacing.md)
            }
            .background(Color.cpBackground)
            .navigationTitle("Profile")
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
}

// MARK: - Profile Stat Item
struct ProfileStatItem: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: CPSpacing.xxs) {
            Text(value)
                .font(.cpTitle2)
                .foregroundStyle(Color.cpLabel)
            Text(label)
                .font(.cpCaption)
                .foregroundStyle(Color.cpSecondaryLabel)
        }
    }
}

// MARK: - Promotion Celebration View
struct PromotionCelebrationView: View {
    @Environment(\.dismiss) private var dismiss
    let fromTier: LeagueTier
    let toTier: LeagueTier

    var body: some View {
        VStack(spacing: CPSpacing.xxl) {
            Spacer()

            // Celebration Animation
            ZStack {
                Circle()
                    .fill(toTier.color.opacity(0.2))
                    .frame(width: 160, height: 160)

                Image(systemName: toTier.icon)
                    .font(.system(size: 70))
                    .foregroundStyle(toTier.color)
            }

            VStack(spacing: CPSpacing.md) {
                Text("Promoted!")
                    .font(.cpTitle)
                    .foregroundStyle(Color.cpLabel)

                HStack(spacing: CPSpacing.sm) {
                    Text(fromTier.rawValue)
                        .font(.cpHeadline)
                        .foregroundStyle(fromTier.color)

                    Image(systemName: "arrow.right")
                        .foregroundStyle(Color.cpSecondaryLabel)

                    Text(toTier.rawValue)
                        .font(.cpHeadline)
                        .foregroundStyle(toTier.color)
                }

                Text("You finished in the top 10!")
                    .font(.cpBody)
                    .foregroundStyle(Color.cpSecondaryLabel)
            }

            // Badge Earned
            HStack(spacing: CPSpacing.md) {
                Image(systemName: "medal.fill")
                    .font(.title2)
                    .foregroundStyle(Color.yellow)

                Text("New badge earned!")
                    .font(.cpHeadline)
                    .foregroundStyle(Color.cpLabel)
            }
            .padding(CPSpacing.md)
            .background(Color.yellow.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: CPCornerRadius.md))

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

// MARK: - Demotion View
struct DemotionView: View {
    @Environment(\.dismiss) private var dismiss
    let fromTier: LeagueTier
    let toTier: LeagueTier

    var body: some View {
        VStack(spacing: CPSpacing.xxl) {
            Spacer()

            // Neutral Icon (not celebratory, not punishing)
            ZStack {
                Circle()
                    .fill(Color.cpSecondaryBackground)
                    .frame(width: 120, height: 120)

                Image(systemName: toTier.icon)
                    .font(.system(size: 50))
                    .foregroundStyle(toTier.color)
            }

            // Neutral, factual messaging
            VStack(spacing: CPSpacing.md) {
                Text("League Changed")
                    .font(.cpTitle2)
                    .foregroundStyle(Color.cpLabel)

                HStack(spacing: CPSpacing.sm) {
                    Text(fromTier.rawValue)
                        .font(.cpHeadline)
                        .foregroundStyle(fromTier.color)

                    Image(systemName: "arrow.right")
                        .foregroundStyle(Color.cpSecondaryLabel)

                    Text(toTier.rawValue)
                        .font(.cpHeadline)
                        .foregroundStyle(toTier.color)
                }

                Text("You'll start fresh in \(toTier.rawValue) League next week.")
                    .font(.cpBody)
                    .foregroundStyle(Color.cpSecondaryLabel)
                    .multilineTextAlignment(.center)
            }

            // Encouragement (not shame)
            VStack(spacing: CPSpacing.sm) {
                Text("Complete more lessons to earn XP")
                    .font(.cpBody)
                    .foregroundStyle(Color.cpSecondaryLabel)
            }

            Spacer()

            Button("Continue") {
                dismiss()
            }
            .cpSecondaryButton()
            .padding(.horizontal, CPSpacing.xl)
            .padding(.bottom, CPSpacing.xxl)
        }
        .background(Color.cpBackground)
    }
}

#Preview {
    LeaguesView()
        .environment(AppStateController())
}
