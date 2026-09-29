# ClearPath Architecture

This document describes the technical architecture of ClearPath, a financial literacy iOS app.

## Table of Contents

1. [Overview](#overview)
2. [App State Management](#app-state-management)
3. [Data Flow](#data-flow)
4. [Feature Modules](#feature-modules)
5. [Design System](#design-system)
6. [Concurrency Model](#concurrency-model)
7. [Common Pitfalls](#common-pitfalls)

---

## Overview

ClearPath follows modern SwiftUI architecture patterns with these key principles:

- **Enum-based State Machine**: App state is explicitly modeled as an enum
- **Thin @main Entry Point**: Business logic lives in controllers, not the app entry
- **Environment-based DI**: Dependencies injected via SwiftUI environment
- **@Observable Pattern**: iOS 17+ observation for reactive UI

### Technology Stack

| Layer | Technology |
|-------|------------|
| UI | SwiftUI (iOS 17+) |
| State | @Observable, @Environment |
| Data | In-memory with UserDefaults persistence |
| Concurrency | Swift 6 strict concurrency |
| Build | Xcode 15+, Swift 6 |

---

## App State Management

### AppStateController

The `AppStateController` is the single source of truth for app-level state.

```swift
@Observable
@MainActor
final class AppStateController {
    private(set) var state: AppState = .loading
    let dataManager = AppDataManager()

    func transition(to newState: AppState) {
        guard isValidTransition(from: state, to: newState) else { return }
        state = newState
    }
}
```

### AppState Enum

```swift
enum AppState: Equatable {
    case loading
    case onboarding(OnboardingStep)
    case authenticated
}

enum OnboardingStep: Equatable {
    case valueProposition
    case sampleLesson
    case sampleLessonComplete
    case signUp
    case goalQuiz
    case pushNotificationSetup
}
```

### State Transition Validation

All state transitions are validated to prevent invalid states:

```swift
private func isValidTransition(from: AppState, to: AppState) -> Bool {
    switch (from, to) {
    case (.loading, .onboarding): return true
    case (.loading, .authenticated): return true
    case (.onboarding, .onboarding): return true  // Step changes
    case (.onboarding, .authenticated): return true
    case (.authenticated, .onboarding): return true  // Logout
    case (.authenticated, .loading): return true     // Reset
    default: return false
    }
}
```

### State Diagram

```
                    ┌───────────────────┐
                    │      Loading      │
                    └─────────┬─────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               │               ▼
    ┌─────────────────┐       │     ┌─────────────────┐
    │   Onboarding    │───────┼────▶│  Authenticated  │
    │                 │       │     │                 │
    │  ┌───────────┐  │       │     └────────┬────────┘
    │  │ValueProp  │  │       │              │
    │  │    ↓      │  │       │              │
    │  │Sample     │  │       │              │
    │  │    ↓      │  │       │              │
    │  │Complete   │  │       │              │
    │  │    ↓      │  │       │              │
    │  │SignUp     │  │       │              │
    │  │    ↓      │  │       │              │
    │  │GoalQuiz   │  │       │              │
    │  │    ↓      │  │       │              │
    │  │PushSetup  │──┼───────┘              │
    │  └───────────┘  │                      │
    └─────────────────┘◀─────────────────────┘
                              (logout)
```

---

## Data Flow

### AppDataManager

Centralized data management through `AppDataManager`:

```swift
@Observable
@MainActor
final class AppDataManager {
    // User State
    var currentUser: User?
    var userProgress: UserProgress

    // Content
    var tracks: [Track]
    var lessons: [Lesson]

    // Gamification
    var streak: StreakData
    var moneyScore: MoneyScore
    var league: League?

    // Persistence
    func saveToUserDefaults()
    func loadFromUserDefaults()
    func resetAllData()
}
```

### Data Ownership

```
┌─────────────────────────────────────────────┐
│              AppStateController              │
│  ┌─────────────────────────────────────┐    │
│  │           AppDataManager            │    │
│  │                                     │    │
│  │  ┌─────────┐  ┌─────────────────┐  │    │
│  │  │  User   │  │  UserProgress   │  │    │
│  │  └─────────┘  └─────────────────┘  │    │
│  │                                     │    │
│  │  ┌─────────┐  ┌─────────────────┐  │    │
│  │  │ Tracks  │  │  MoneyScore     │  │    │
│  │  └─────────┘  └─────────────────┘  │    │
│  │                                     │    │
│  │  ┌─────────┐  ┌─────────────────┐  │    │
│  │  │ Streak  │  │     League      │  │    │
│  │  └─────────┘  └─────────────────┘  │    │
│  └─────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
```

### Environment Injection

Dependencies flow down through SwiftUI's environment:

```swift
// App Entry
@main
struct ClearPathApp: App {
    @State private var appState = AppStateController()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
        }
    }
}

// Feature View
struct HomeTab: View {
    @Environment(AppStateController.self) private var appState

    var body: some View {
        // Access appState.dataManager for data
    }
}
```

---

## Feature Modules

### Module Organization

Each feature is self-contained in its own directory:

```
Features/
├── Onboarding/
│   ├── ValuePropCarouselView.swift
│   ├── SampleLessonView.swift
│   ├── SampleLessonCompleteView.swift
│   ├── SignUpView.swift
│   ├── GoalQuizView.swift
│   └── PushNotificationSetupView.swift
├── Home/
│   └── (HomeTab in MainTabView)
├── Learn/
│   ├── LearnTab.swift
│   └── TrackDetailView.swift
├── Lessons/
│   ├── LessonView.swift
│   └── LessonCompleteView.swift
├── MoneyLab/
│   ├── MoneyLabTab.swift
│   └── SimulatorView.swift
├── Progress/
│   ├── MoneyScoreView.swift
│   └── StreakDetailView.swift
├── Social/
│   └── LeaguesView.swift
├── Profile/
│   └── SettingsView.swift
└── Paywall/
    ├── PaywallView.swift
    └── ReverseTrialEndView.swift
```

### Feature Dependencies

```
┌──────────────┐     ┌──────────────┐
│  Onboarding  │────▶│     Home     │
└──────────────┘     └──────┬───────┘
                            │
         ┌──────────────────┼──────────────────┐
         │                  │                  │
         ▼                  ▼                  ▼
   ┌───────────┐     ┌───────────┐     ┌───────────┐
   │   Learn   │     │  MoneyLab │     │  Profile  │
   └─────┬─────┘     └───────────┘     └───────────┘
         │
         ▼
   ┌───────────┐
   │  Lessons  │
   └─────┬─────┘
         │
         ▼
   ┌───────────┐
   │  Progress │
   └───────────┘
```

### Navigation Structure

```swift
// MainTabView defines the tab structure
enum Tab: Int {
    case home
    case learn
    case leagues
    case lab
    case profile
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab().tag(Tab.home)
            LearnTab().tag(Tab.learn)
            LeaguesView().tag(Tab.leagues)
            MoneyLabTab().tag(Tab.lab)
            ProfileTab().tag(Tab.profile)
        }
    }
}
```

---

## Design System

### Color Tokens

All colors use semantic tokens defined in `Colors.swift`:

```swift
extension Color {
    // Brand
    static let cpPrimary = Color.blue
    static let cpSecondary = Color.purple
    static let cpAccent = Color.orange

    // Semantic
    static let cpSuccess = Color.green
    static let cpError = Color.red
    static let cpWarning = Color.orange

    // Backgrounds (system-aware)
    static let cpBackground = Color(uiColor: .systemBackground)
    static let cpSecondaryBackground = Color(uiColor: .secondarySystemBackground)

    // Text (system-aware)
    static let cpLabel = Color(uiColor: .label)
    static let cpSecondaryLabel = Color(uiColor: .secondaryLabel)
}
```

### Typography

Text styles follow Apple's Dynamic Type:

```swift
extension Font {
    static let cpLargeTitle = Font.largeTitle.weight(.bold)
    static let cpTitle = Font.title2.weight(.semibold)
    static let cpHeadline = Font.headline
    static let cpBody = Font.body
    static let cpCaption = Font.caption
}
```

### Components

Reusable components in `Components/`:

| Component | Usage |
|-----------|-------|
| `PrimaryButton` | Main action buttons |
| `SecondaryButton` | Secondary actions |
| `InfoBox` | Information callouts |
| `ProgressRing` | Circular progress indicators |
| `StreakCalendar` | Streak visualization |

---

## Concurrency Model

### Swift 6 Strict Concurrency

The app uses Swift 6 strict concurrency with these patterns:

#### @MainActor for UI

```swift
@Observable
@MainActor
final class AppStateController {
    // All UI-related state
}

@Observable
@MainActor
final class AppDataManager {
    // All data that drives UI
}
```

#### Sendable Models

All models conform to `Sendable` (automatically for value types):

```swift
struct User: Codable, Equatable, Sendable {
    let id: UUID
    var displayName: String
    // ...
}
```

#### Async Initialization

```swift
@main
struct ClearPathApp: App {
    @State private var appState = AppStateController()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .task {
                    await appState.initialize()
                }
        }
    }
}
```

### Thread Safety

| Component | Thread | Pattern |
|-----------|--------|---------|
| AppStateController | Main | @MainActor |
| AppDataManager | Main | @MainActor |
| Views | Main | SwiftUI automatic |
| Calculations | Main | Synchronous (fast) |

---

## Testing Strategy

### Unit Tests

- Test state transitions in `AppStateController`
- Test calculations in simulator models
- Test data transformations in `AppDataManager`

### UI Tests

- Test onboarding flow end-to-end
- Test lesson completion flow
- Test navigation between tabs

### Debug Menu

For development testing, use the Debug Menu (DEBUG builds only):

```swift
// Access from any screen via floating button
.withDebugMenu()

// Force any app state
appState.forceState(.authenticated)

// Setup test users
setupActiveUser()
setupProUser()
setupTrialEndingUser()
```

**Access control note**: `AppStateController.state`, `AppDataManager.streak`, and `AppDataManager.userProgress` are `private(set)`. Since Swift `private` is file-scoped, `DebugMenu.swift` cannot assign to them directly — even via extension. `#if DEBUG` mutator methods (`forceState`, `debugSetStreak`, `debugSetConceptMastery`) live in the same file as each owning class specifically so they retain access to the private setter. See [CONTRIBUTING.md](CONTRIBUTING.md#adding-debug-actions) before adding new debug mutations.

---

## Common Pitfalls

### Avoid Nested Sheet Presentations

Do not present a `.sheet` from within a view that is itself already being presented as a `.sheet`, especially synchronously from `.onAppear`. This races against the parent sheet's own UIKit presentation-controller transition and can render as a fully blank, chrome-less modal.

**Bug encountered**: `StreakDetailView` (itself presented via `.sheet` from `MainTabView`) called `checkForMilestone()` in `.onAppear`, which triggered a second `.sheet(isPresented: $showingMilestone)` to show `MilestoneCelebrationView`. This produced a blank sheet every time the streak was at a milestone value (7/30/100/365 days).

**Fix**: Present secondary content that should appear within an already-presented sheet using `.overlay` + `.transition`/`.animation` instead of a second `.sheet`. This avoids a second UIKit presentation controller entirely, sidestepping the race condition.

```swift
// ❌ Avoid — sheet-on-sheet
.sheet(isPresented: $showingMilestone) {
    MilestoneCelebrationView(milestone: milestone)
}

// ✅ Prefer — overlay within the existing presentation
.overlay {
    if showingMilestone {
        MilestoneCelebrationView(milestone: milestone) {
            showingMilestone = false
        }
        .transition(.opacity)
    }
}
.animation(.default, value: showingMilestone)
```

### ForEach Requires Unique IDs

`ForEach(_:id:)` requires unique identifiers. Using `id: \.self` on a collection with duplicate values (e.g. weekday initials `["S","M","T","W","T","F","S"]`) triggers SwiftUI Fault-level diagnostics and undefined rendering behavior. Use `.enumerated()` with `id: \.offset` for collections that may contain repeated values:

```swift
ForEach(Array(days.enumerated()), id: \.offset) { _, day in
    Text(day)
}
```

### One-Time Events Need Persisted State

A condition based purely on current data state (e.g. `streak.currentStreak == 7`) will re-trigger every time that state is observed — including every time the containing view reappears. For one-time events like milestone celebrations, persist which events have already fired (`Streak.celebratedMilestones: Set<Int>`) and check against that set, not just the raw condition.

---

## Future Considerations

### Planned Enhancements

1. **CloudKit Sync**: Sync progress across devices
2. **Offline Support**: Cache lessons for offline use
3. **Widget Extension**: Show streak and score on home screen
4. **Watch App**: Quick lesson reminders

### Scalability

- Current in-memory model works for MVP
- Future: Consider SwiftData for complex queries
- Future: Consider background refresh for league updates

---

## References

- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
