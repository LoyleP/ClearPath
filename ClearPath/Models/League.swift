import Foundation
import SwiftUI

// MARK: - League Model
struct League: Identifiable, Codable, Equatable {
    let id: UUID
    let tier: LeagueTier
    var members: [LeagueMember]
    var weekStartDate: Date
    var weekEndDate: Date
    var currentUserID: UUID

    var sortedMembers: [LeagueMember] {
        members.sorted { $0.weeklyXP > $1.weeklyXP }
    }

    var currentUserRank: Int {
        rank(for: currentUserID) ?? 0
    }

    // Top 10 get promoted
    var promotionZone: [LeagueMember] {
        Array(sortedMembers.prefix(10))
    }

    // Bottom 5 get demoted
    var demotionZone: [LeagueMember] {
        Array(sortedMembers.suffix(5))
    }

    func rank(for userID: UUID) -> Int? {
        sortedMembers.firstIndex { $0.userID == userID }.map { $0 + 1 }
    }

    func zone(for userID: UUID) -> LeagueZone {
        guard let rank = rank(for: userID) else { return .safe }
        if rank <= 10 { return .promotion }
        if rank > members.count - 5 { return .demotion }
        return .safe
    }
}

// MARK: - League Tier
enum LeagueTier: String, CaseIterable, Codable, Comparable {
    case bronze = "Bronze"
    case silver = "Silver"
    case gold = "Gold"
    case platinum = "Platinum"
    case diamond = "Diamond"

    var color: Color {
        switch self {
        case .bronze: return .cpBronze
        case .silver: return .cpSilver
        case .gold: return .cpGold
        case .platinum: return .cpPlatinum
        case .diamond: return .cpDiamond
        }
    }

    var icon: String {
        switch self {
        case .bronze: return "shield.fill"
        case .silver: return "shield.fill"
        case .gold: return "star.fill"
        case .platinum: return "crown.fill"
        case .diamond: return "diamond.fill"
        }
    }

    var nextTier: LeagueTier? {
        switch self {
        case .bronze: return .silver
        case .silver: return .gold
        case .gold: return .platinum
        case .platinum: return .diamond
        case .diamond: return nil
        }
    }

    var previousTier: LeagueTier? {
        switch self {
        case .bronze: return nil
        case .silver: return .bronze
        case .gold: return .silver
        case .platinum: return .gold
        case .diamond: return .platinum
        }
    }

    static func < (lhs: LeagueTier, rhs: LeagueTier) -> Bool {
        let order: [LeagueTier] = [.bronze, .silver, .gold, .platinum, .diamond]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else { return false }
        return lhsIndex < rhsIndex
    }
}

// MARK: - League Zone
enum LeagueZone {
    case promotion
    case safe
    case demotion
}

// MARK: - League Member
struct LeagueMember: Identifiable, Codable, Equatable {
    let id: UUID
    let userID: UUID
    let displayName: String
    let avatarURL: URL?
    var weeklyXP: Int

    init(id: UUID = UUID(), userID: UUID, displayName: String, avatarURL: URL? = nil, weeklyXP: Int = 0) {
        self.id = id
        self.userID = userID
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.weeklyXP = weeklyXP
    }
}

// MARK: - Friend
struct Friend: Identifiable, Codable, Equatable {
    let id: UUID
    let userID: UUID
    let displayName: String
    let avatarURL: URL?
    var currentStreak: Int
    var totalScore: Int
    var badgeCount: Int

    init(id: UUID = UUID(), userID: UUID, displayName: String, avatarURL: URL? = nil, currentStreak: Int = 0, totalScore: Int = 0, badgeCount: Int = 0) {
        self.id = id
        self.userID = userID
        self.displayName = displayName
        self.avatarURL = avatarURL
        self.currentStreak = currentStreak
        self.totalScore = totalScore
        self.badgeCount = badgeCount
    }
}
