import SwiftUI

@main
struct KnockoutRoyale777App: App {
    @StateObject private var store = GameStore()
    @State private var showSplash = true
    @State private var splashDuration = Double.random(in: 3.0...6.0)

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .environmentObject(store)
                    .opacity(showSplash ? 0 : 1)

                if showSplash {
                    SplashView(duration: splashDuration)
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .animation(.easeInOut(duration: 0.45), value: showSplash)
            .task {
                try? await Task.sleep(nanoseconds: UInt64(splashDuration * 1_000_000_000))
                showSplash = false
            }
        }
    }
}
