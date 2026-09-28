# Contributing to ClearPath

This guide covers development setup, coding standards, and contribution workflow.

## Table of Contents

1. [Development Setup](#development-setup)
2. [Project Structure](#project-structure)
3. [Coding Standards](#coding-standards)
4. [Debug Tools](#debug-tools)
5. [Git Workflow](#git-workflow)
6. [Testing](#testing)

---

## Development Setup

### Requirements

- macOS 14.0+ (Sonoma)
- Xcode 15.0+
- iOS 17.0+ Simulator or device

### Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/LoyleP/ClearPath.git
   cd ClearPath
   ```

2. **Open in Xcode**
   ```bash
   open ClearPath.xcodeproj
   ```

3. **Select scheme and destination**
   - Scheme: `ClearPath`
   - Destination: Any iOS 17+ simulator

4. **Build and run**
   - Press `Cmd+R` or click the Play button

### First Run

On first launch, you'll see the onboarding flow. To skip this during development:

1. Build and run in DEBUG mode
2. Tap the red ladybug button (bottom-right corner)
3. Select "→ Authenticated (Main App)" to jump to the main app

---

## Project Structure

```
ClearPath/
├── App/                    # App lifecycle
│   ├── ClearPathApp.swift  # @main entry point
│   ├── AppState.swift      # State machine
│   └── RootView.swift      # Root view switching
│
├── Models/                 # Data models
│   ├── User.swift
│   ├── Lesson.swift
│   ├── League.swift
│   ├── Streak.swift
│   └── MoneyLab.swift
│
├── Services/               # Business logic
│   └── AppDataManager.swift
│
├── Features/               # Feature modules
│   ├── Onboarding/
│   ├── Home/
│   ├── Learn/
│   ├── Lessons/
│   ├── MoneyLab/
│   ├── Progress/
│   ├── Social/
│   ├── Profile/
│   └── Paywall/
│
├── Components/             # Reusable UI
│
├── DesignSystem/           # Design tokens
│   ├── Colors.swift
│   └── Typography.swift
│
└── Debug/                  # Development tools
    └── DebugMenu.swift
```

### Where to Add New Code

| Type | Location |
|------|----------|
| New screen | `Features/<FeatureName>/` |
| Reusable component | `Components/` |
| Data model | `Models/` |
| Business logic | `Services/` |
| Color/font token | `DesignSystem/` |
| Debug helper | `Debug/` |

---

## Coding Standards

### Swift Style

#### Naming

```swift
// Types: UpperCamelCase
struct UserProfile { }
enum SubscriptionStatus { }

// Variables/Functions: lowerCamelCase
let currentUser: User
func calculateScore() -> Int

// Constants: lowerCamelCase
let maximumRetries = 3
```

#### File Organization

Use `// MARK: -` to organize code:

```swift
import SwiftUI

struct MyView: View {
    // MARK: - Environment
    @Environment(AppStateController.self) private var appState

    // MARK: - State
    @State private var isLoading = false

    // MARK: - Body
    var body: some View {
        // ...
    }

    // MARK: - Actions
    private func handleTap() {
        // ...
    }

    // MARK: - Helpers
    private func formatDate(_ date: Date) -> String {
        // ...
    }
}
```

### SwiftUI Patterns

#### View Structure

```swift
struct FeatureView: View {
    // 1. Environment
    @Environment(AppStateController.self) private var appState
    @Environment(\.dismiss) private var dismiss

    // 2. State
    @State private var selection: Item?

    // 3. Properties
    let items: [Item]

    // 4. Body
    var body: some View {
        // Keep body simple, extract subviews
    }

    // 5. Computed Views
    @ViewBuilder
    private var headerSection: some View {
        // Complex view logic
    }

    // 6. Actions
    private func handleSelection(_ item: Item) {
        // Action logic
    }
}
```

#### Prefer Composition

```swift
// ✅ Good: Extracted subview
var body: some View {
    VStack {
        HeaderView(title: "Dashboard")
        ContentSection(items: items)
        FooterButtons(onSave: save, onCancel: cancel)
    }
}

// ❌ Avoid: Massive body
var body: some View {
    VStack {
        // 200 lines of nested views...
    }
}
```

### Concurrency

#### Use @MainActor for UI

```swift
@Observable
@MainActor
final class FeatureViewModel {
    var items: [Item] = []

    func loadItems() async {
        items = await fetchItems()
    }
}
```

#### Mark async boundaries

```swift
struct MyView: View {
    var body: some View {
        Button("Load") {
            Task {
                await viewModel.loadItems()
            }
        }
    }
}
```

---

## Debug Tools

### Debug Menu

Available in DEBUG builds only. Access via the red ladybug button.

#### App State Shortcuts

| Action | Effect |
|--------|--------|
| → Loading | Shows loading screen |
| → Onboarding: Value Prop | First onboarding screen |
| → Onboarding: Sample Lesson | Sample lesson flow |
| → Onboarding: Sign Up | Sign up screen |
| → Onboarding: Goal Quiz | Goal selection |
| → Authenticated | Main app |

#### Quick Setup

| Setup | Creates |
|-------|---------|
| New User | Fresh user, no progress |
| Active User | User with 5 lessons, 7-day streak |
| Pro User | Active user with Pro subscription |
| Trial Ending | Active user on day 7 of trial |

#### Direct Screen Access

Jump directly to any screen:
- Paywall
- Reverse Trial End
- Money Score Detail
- Streak Detail
- Leagues
- Settings
- All Money Lab Simulators
- Sample Lessons

#### Data Manipulation

| Action | Effect |
|--------|--------|
| Reset All Data | Clears everything, returns to onboarding |
| Add 10 Day Streak | Creates streak history |
| Add 5 Completed Lessons | Marks lessons as done |
| Trigger Fading Concepts | Creates concepts due for review |

### Adding Debug Actions

```swift
// In DebugMenu.swift
Section("My Debug Actions") {
    Button("My Action") {
        // Debug action
        dismiss()
    }
}
```

### Console Logging

State transitions are logged in DEBUG:

```
🔄 AppState: loading → onboarding(valueProposition)
🔄 AppState: onboarding(valueProposition) → onboarding(sampleLesson)
```

---

## Git Workflow

### Branch Naming

```
feature/add-lesson-reminders
bugfix/fix-streak-calculation
refactor/extract-progress-component
```

### Commit Messages

Follow conventional commits:

```
feat: add push notification scheduling
fix: correct streak calculation for timezone
refactor: extract MoneyScoreCard component
docs: update architecture documentation
test: add unit tests for debt calculator
```

### Pull Request Process

1. Create feature branch from `main`
2. Make changes with clear commits
3. Test on multiple simulators
4. Run all tests
5. Create PR with description
6. Address review feedback
7. Merge when approved

---

## Testing

### Running Tests

```bash
# Command line
xcodebuild test \
  -scheme ClearPath \
  -destination 'platform=iOS Simulator,name=iPhone 15'

# Or in Xcode
Cmd+U
```

### Test Categories

| Category | Focus |
|----------|-------|
| Unit | Model logic, calculations |
| Integration | Data flow, state transitions |
| UI | User flows, navigation |

### Writing Tests

```swift
import Testing

@Test func streakCalculation() async throws {
    let streak = StreakData()
    streak.recordActivity(for: Date())

    #expect(streak.currentStreak == 1)
}
```

### Debug Menu for Manual Testing

Use Quick Setup options to rapidly test scenarios:

1. Test **new user experience**: "Setup: New User"
2. Test **active user flows**: "Setup: Active User"
3. Test **paywall conversion**: "Setup: Trial Ending"
4. Test **pro features**: "Setup: Pro User"

---

## Common Tasks

### Adding a New Screen

1. Create file in appropriate `Features/` subfolder
2. Follow view structure pattern
3. Add navigation from parent view
4. Add to Debug Menu for quick access

### Adding a New Model

1. Create file in `Models/`
2. Conform to `Codable, Equatable` minimum
3. Add to `AppDataManager` if needed
4. Update mock data for testing

### Adding a Design Token

1. Add to `Colors.swift` or `Typography.swift`
2. Follow existing naming pattern (`cp` prefix)
3. Use semantic naming (purpose, not appearance)

---

## Getting Help

- Check `ARCHITECTURE.md` for system design
- Check `README.md` for feature overview
- Use Debug Menu to explore the app
- Review existing code for patterns
