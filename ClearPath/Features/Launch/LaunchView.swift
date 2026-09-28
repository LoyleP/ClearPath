import SwiftUI

/// Shown while `AppStateController` is still in `.loading`.
struct LaunchView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.trend.up.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
            Text("ClearPath")
                .font(.title2.bold())
        }
    }
}

#Preview {
    LaunchView()
}
