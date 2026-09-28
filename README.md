# ClearPath

A Duolingo-style financial literacy iOS app designed for US users. ClearPath gamifies personal finance education through bite-sized lessons, interactive simulators, and social features.

![iOS 17+](https://img.shields.io/badge/iOS-17%2B-blue)
![Swift 6](https://img.shields.io/badge/Swift-6-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-Enabled-green)

## Features

### Core Learning Experience

- **Bite-sized Lessons**: 3-5 minute lessons with adaptive difficulty
- **Knowledge Decay System**: Spaced repetition with 5 mastery levels
- **Fading Concepts**: Visual indicators when knowledge needs refreshing
- **Progress Tracking**: Track completion across multiple learning tracks

### Money Lab (Interactive Simulators)

Five on-device financial simulators with real-time calculations:

| Simulator | Description |
|-----------|-------------|
| **Paycheck Breakdown** | Understand gross vs net, taxes, deductions |
| **Debt Payoff** | Compare avalanche vs snowball strategies |
| **Compound Growth** | Visualize investment growth over time |
| **Budget Allocator** | Apply 50/30/20 rule to your income |
| **Credit Utilization** | See impact on credit score |

### Gamification

- **Money Score (0-100)**: Composite score based on:
  - Knowledge (60%): Quiz accuracy, concept mastery
  - Behaviour (25%): Consistent app usage, goal progress
  - Consistency (15%): Streak maintenance, daily engagement

- **Streak System**:
  - Daily streak tracking with calendar visualization
  - Streak Shield: Earned every 10 days (max 2 shields)
  - Automatic protection from streak loss

- **Leagues**:
  - 5 tiers: Bronze → Silver → Gold → Platinum → Diamond
  - Weekly competitions with promotion/demotion zones
  - Friends leaderboard with social features

### Monetization

- **Reverse Trial**: 7 days free premium, no credit card required
- **Pro Features**: Ad-free, unlimited hearts, exclusive content
- **Privacy-First**: All calculations happen on-device

## Architecture

### Project Structure

```
ClearPath/
├── App/
│   ├── ClearPathApp.swift      # @main entry point (thin shell)
│   ├── AppState.swift          # Enum-based state machine
│   └── RootView.swift          # Root view switching
├── Models/
│   ├── User.swift              # User profile and preferences
│   ├── Lesson.swift            # Lesson content and progress
│   ├── League.swift            # Social/competitive features
│   ├── Streak.swift            # Streak tracking
│   └── MoneyLab.swift          # Simulator input/output models
├── Services/
│   └── AppDataManager.swift    # Centralized data management
├── Features/
│   ├── Onboarding/             # Value prop, sample lesson, signup
│   ├── Home/                   # Dashboard and quick actions
│   ├── Learn/                  # Lesson browsing and tracks
│   ├── Lessons/                # Lesson delivery and completion
│   ├── MoneyLab/               # Interactive simulators
│   ├── Progress/               # Money Score and achievements
│   ├── Social/                 # Leagues and friends
│   ├── Profile/                # Settings and preferences
│   └── Paywall/                # Subscription and trial
├── Components/                 # Reusable UI components
├── DesignSystem/
│   ├── Colors.swift            # Semantic color palette
│   └── Typography.swift        # Text styles
└── Debug/
    └── DebugMenu.swift         # Development shortcuts (DEBUG only)
```

### Design Patterns

- **AppStateController Pattern**: Enum-based state machine with validated transitions
- **@Observable (iOS 17+)**: Modern observation for reactive UI
- **Thin @main Entry**: All logic delegated to AppStateController
- **Environment Injection**: Dependencies passed via SwiftUI environment

### State Machine

```
┌─────────────┐
│   Loading   │
└──────┬──────┘
       │
       ├─────────────────────┐
       ▼                     ▼
┌─────────────┐       ┌─────────────┐
│ Onboarding  │──────▶│Authenticated│
└─────────────┘       └─────────────┘
       │                     │
       │◀────────────────────┘
       │        (logout)
```

**Onboarding Steps:**
1. Value Proposition (3-screen carousel)
2. Sample Lesson (free trial lesson)
3. Sample Lesson Complete
4. Sign Up / Log In
5. Goal Quiz (personalization)
6. Push Notification Setup

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 6

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/LoyleP/ClearPath.git
   ```

2. Open in Xcode:
   ```bash
   cd ClearPath
   open ClearPath.xcodeproj
   ```

3. Build and run on simulator or device

## Debug Menu (Development Only)

In DEBUG builds, a red ladybug button appears in the bottom-right corner. Tap it to access:

| Section | Actions |
|---------|---------|
| **App State** | Jump to Loading, Onboarding steps, or Authenticated |
| **Quick Setup** | Create test users (New, Active, Pro, Trial Ending) |
| **Open Screens** | Direct access to Paywall, Money Score, Leagues, Settings |
| **Money Lab** | Open any simulator directly |
| **Sample Lessons** | Test lesson flows |
| **Data** | Reset data, add streaks, trigger fading concepts |

## User Flows

### Onboarding Flow

```
Launch → Value Prop Carousel → Try Sample Lesson →
Sample Complete → Sign Up → Goal Quiz →
Push Setup → Main App
```

### Learning Flow

```
Home → Select Track → Select Lesson →
Complete Questions → Lesson Complete →
Update Progress → Return to Track
```

### Money Lab Flow

```
Lab Tab → Select Simulator → Enter Parameters →
Calculate Results → (Optional) Save Scenario →
View Saved Scenarios
```

## Design System

### Colors

| Token | Usage |
|-------|-------|
| `cpPrimary` | Primary actions, links |
| `cpSecondary` | Secondary elements |
| `cpAccent` | Highlights, badges |
| `cpSuccess` | Correct answers, achievements |
| `cpError` | Errors, streak loss |
| `cpWarning` | Warnings, fading concepts |

### League Tier Colors

| Tier | Color |
|------|-------|
| Bronze | `cpBronze` |
| Silver | `cpSilver` |
| Gold | `cpGold` |
| Platinum | `cpPlatinum` |
| Diamond | `cpDiamond` |

## Data Models

### User

```swift
struct User {
    let id: UUID
    var displayName: String
    var email: String?
    var authProvider: AuthProvider
    var preferredGoal: FinancialGoal?
    var subscriptionStatus: SubscriptionStatus
    var reverseTrialStartDate: Date?
}
```

### Lesson Progress

```swift
struct LessonProgress {
    var completedAt: Date?
    var correctAnswers: Int
    var totalQuestions: Int
    var timeTaken: TimeInterval
}
```

### Money Score

```swift
struct MoneyScore {
    var knowledge: Double      // 0-100, weight: 60%
    var behaviour: Double      // 0-100, weight: 25%
    var consistency: Double    // 0-100, weight: 15%

    var total: Double {
        knowledge * 0.6 + behaviour * 0.25 + consistency * 0.15
    }
}
```

## Testing

### Unit Tests
```bash
xcodebuild test -scheme ClearPath -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Debug Shortcuts
Use the Debug Menu to quickly set up test scenarios without going through full flows.

## Privacy

- All financial calculations happen on-device
- No personal financial data is transmitted to servers
- Simulator inputs are stored locally only
- User can export or delete all data from Settings

## License

Copyright 2024. All rights reserved.

## Acknowledgments

- Built with SwiftUI and modern iOS patterns
- Follows Apple Human Interface Guidelines
- Inspired by Duolingo's gamification approach
