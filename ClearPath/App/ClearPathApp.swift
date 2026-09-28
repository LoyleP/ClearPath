import SwiftUI

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
