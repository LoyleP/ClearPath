import SwiftUI

// MARK: - Value Proposition Carousel
struct ValuePropCarouselView: View {
    @Environment(AppStateController.self) private var appState
    @State private var currentPage = 0

    private let pages: [ValuePropPage] = [
        ValuePropPage(
            icon: "chart.line.uptrend.xyaxis.circle.fill",
            title: "Track your money",
            description: "Build real financial knowledge with bite-sized lessons that stick.",
            color: .blue
        ),
        ValuePropPage(
            icon: "flame.circle.fill",
            title: "Build daily habits",
            description: "Just 3 minutes a day builds lasting financial literacy through streaks and practice.",
            color: .orange
        ),
        ValuePropPage(
            icon: "checkmark.shield.fill",
            title: "Trust our content",
            description: "No bank pays us. No affiliate links. Just clear, unbiased financial education.",
            color: .green
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Page Content
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    ValuePropPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            // Bottom Section
            VStack(spacing: CPSpacing.lg) {
                // Page Indicators
                HStack(spacing: CPSpacing.xs) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.blue : Color.cpSecondaryLabel.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }

                // CTA Button
                Button {
                    appState.advanceOnboarding(to: .sampleLesson)
                } label: {
                    Text(currentPage == pages.count - 1 ? "Try a free lesson" : "Get started")
                }
                .cpPrimaryButton()

                // Skip option
                if currentPage < pages.count - 1 {
                    Button {
                        appState.advanceOnboarding(to: .sampleLesson)
                    } label: {
                        Text("Skip")
                    }
                    .cpTextButton()
                }
            }
            .padding(.horizontal, CPSpacing.xl)
            .padding(.bottom, CPSpacing.xxl)
        }
        .background(Color.cpBackground)
    }
}

// MARK: - Value Prop Page Model
struct ValuePropPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Value Prop Page View
struct ValuePropPageView: View {
    let page: ValuePropPage

    var body: some View {
        VStack(spacing: CPSpacing.xl) {
            Spacer()

            // Icon
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.15))
                    .frame(width: 160, height: 160)

                Image(systemName: page.icon)
                    .font(.system(size: 80))
                    .foregroundStyle(page.color)
            }

            // Title
            Text(page.title)
                .font(.cpTitle)
                .foregroundStyle(Color.cpLabel)
                .multilineTextAlignment(.center)

            // Description
            Text(page.description)
                .font(.cpBody)
                .foregroundStyle(Color.cpSecondaryLabel)
                .multilineTextAlignment(.center)
                .padding(.horizontal, CPSpacing.xl)

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    ValuePropCarouselView()
        .environment(AppStateController())
}
