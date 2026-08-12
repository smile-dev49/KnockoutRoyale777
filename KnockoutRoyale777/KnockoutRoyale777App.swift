import SwiftUI

@main
struct KnockoutRoyale777App: App {
    @StateObject private var store = GameStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
        }
    }
}
