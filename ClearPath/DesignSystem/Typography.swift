import SwiftUI

// MARK: - ClearPath Typography
// Based on Apple HIG: Dynamic Type support, no light font weights

extension Font {
    // MARK: - Display Fonts (Large numbers, scores)
    static let cpDisplayLarge = Font.system(size: 56, weight: .bold, design: .rounded)
    static let cpDisplayMedium = Font.system(size: 44, weight: .bold, design: .rounded)
    static let cpDisplaySmall = Font.system(size: 34, weight: .semibold, design: .rounded)

    // MARK: - Heading Fonts
    static let cpHeadline = Font.headline.weight(.semibold)
    static let cpTitle = Font.title.weight(.bold)
    static let cpTitle2 = Font.title2.weight(.semibold)
    static let cpTitle3 = Font.title3.weight(.semibold)

    // MARK: - Body Fonts
    static let cpBody = Font.body
    static let cpBodyBold = Font.body.weight(.semibold)
    static let cpCallout = Font.callout
    static let cpCalloutBold = Font.callout.weight(.semibold)

    // MARK: - Caption Fonts
    static let cpCaption = Font.caption
    static let cpCaption2 = Font.caption2
    static let cpFootnote = Font.footnote

    // MARK: - Special Purpose
    static let cpStreakNumber = Font.system(size: 32, weight: .bold, design: .rounded)
    static let cpScoreNumber = Font.system(size: 72, weight: .bold, design: .rounded)
    static let cpQuestionText = Font.title3.weight(.medium)
    static let cpAnswerOption = Font.body.weight(.medium)
}

// MARK: - Text Styles View Modifier
struct CPTextStyle: ViewModifier {
    enum Style {
        case displayLarge
        case displayMedium
        case headline
        case body
        case caption
        case score
    }

    let style: Style

    func body(content: Content) -> some View {
        switch style {
        case .displayLarge:
            content.font(.cpDisplayLarge)
        case .displayMedium:
            content.font(.cpDisplayMedium)
        case .headline:
            content.font(.cpHeadline)
        case .body:
            content.font(.cpBody)
        case .caption:
            content.font(.cpCaption)
        case .score:
            content.font(.cpScoreNumber)
        }
    }
}

extension View {
    func cpTextStyle(_ style: CPTextStyle.Style) -> some View {
        modifier(CPTextStyle(style: style))
    }
}
