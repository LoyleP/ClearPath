import SwiftUI

// MARK: - ClearPath Color Palette
// Based on Apple HIG: semantic colors with light/dark support

extension Color {
    // MARK: - Brand Colors
    // Using standard colors as fallbacks for MVP (asset catalog optional)
    static let cpPrimary = Color.blue
    static let cpSecondary = Color.purple
    static let cpAccent = Color.orange

    // MARK: - Semantic Colors (Fallbacks if asset catalog not configured)
    static let cpSuccess = Color.green
    static let cpError = Color.red
    static let cpWarning = Color.orange

    // MARK: - Background Colors
    static let cpBackground = Color(uiColor: .systemBackground)
    static let cpSecondaryBackground = Color(uiColor: .secondarySystemBackground)
    static let cpTertiaryBackground = Color(uiColor: .tertiarySystemBackground)
    static let cpGroupedBackground = Color(uiColor: .systemGroupedBackground)

    // MARK: - Text Colors
    static let cpLabel = Color(uiColor: .label)
    static let cpSecondaryLabel = Color(uiColor: .secondaryLabel)
    static let cpTertiaryLabel = Color(uiColor: .tertiaryLabel)
    static let cpQuaternaryLabel = Color(uiColor: .quaternaryLabel)

    // MARK: - Streak Colors
    static let cpStreakActive = Color.orange
    static let cpStreakInactive = Color.gray.opacity(0.3)
    static let cpStreakShield = Color.blue

    // MARK: - Money Score Colors
    static let cpScoreKnowledge = Color.blue
    static let cpScoreBehaviour = Color.green
    static let cpScoreConsistency = Color.purple

    // MARK: - League Tier Colors
    static let cpBronze = Color(red: 0.8, green: 0.5, blue: 0.2)
    static let cpSilver = Color.gray
    static let cpGold = Color.yellow
    static let cpPlatinum = Color(red: 0.9, green: 0.9, blue: 0.95)
    static let cpDiamond = Color.cyan
}

// MARK: - Gradient Definitions
@MainActor
extension LinearGradient {
    static let cpPrimaryGradient = LinearGradient(
        colors: [Color.cpPrimary, Color.cpSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cpSuccessGradient = LinearGradient(
        colors: [Color.green, Color.mint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let cpStreakGradient = LinearGradient(
        colors: [Color.orange, Color.red],
        startPoint: .leading,
        endPoint: .trailing
    )
}
