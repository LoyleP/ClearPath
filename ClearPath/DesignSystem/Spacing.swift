import SwiftUI

// MARK: - ClearPath Spacing System
// Consistent spacing throughout the app

enum CPSpacing {
    /// 4pt - Minimal spacing
    static let xxs: CGFloat = 4
    /// 8pt - Extra small spacing
    static let xs: CGFloat = 8
    /// 12pt - Small spacing
    static let sm: CGFloat = 12
    /// 16pt - Medium spacing (default)
    static let md: CGFloat = 16
    /// 20pt - Medium-large spacing
    static let lg: CGFloat = 20
    /// 24pt - Large spacing
    static let xl: CGFloat = 24
    /// 32pt - Extra large spacing
    static let xxl: CGFloat = 32
    /// 48pt - Section spacing
    static let section: CGFloat = 48
}

// MARK: - Corner Radius
enum CPCornerRadius {
    /// 4pt - Small elements
    static let xs: CGFloat = 4
    /// 8pt - Buttons, small cards
    static let sm: CGFloat = 8
    /// 12pt - Cards, containers
    static let md: CGFloat = 12
    /// 16pt - Large cards
    static let lg: CGFloat = 16
    /// 20pt - Hero cards
    static let xl: CGFloat = 20
    /// Full circular
    static let full: CGFloat = 999
}

// MARK: - Touch Target
enum CPTouchTarget {
    /// 44pt - Minimum touch target (Apple HIG)
    static let minimum: CGFloat = 44
    /// 48pt - Comfortable touch target
    static let comfortable: CGFloat = 48
    /// 56pt - Large touch target
    static let large: CGFloat = 56
}

// MARK: - Padding Convenience
extension View {
    func cpPadding(_ spacing: CGFloat = CPSpacing.md) -> some View {
        padding(spacing)
    }

    func cpHorizontalPadding(_ spacing: CGFloat = CPSpacing.md) -> some View {
        padding(.horizontal, spacing)
    }

    func cpVerticalPadding(_ spacing: CGFloat = CPSpacing.md) -> some View {
        padding(.vertical, spacing)
    }

    func cpCardPadding() -> some View {
        padding(CPSpacing.md)
    }
}
