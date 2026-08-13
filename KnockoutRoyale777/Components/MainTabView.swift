import SwiftUI

enum AppTab: Hashable {
    case home
    case rewards
    case profile
}

struct MainTabView: View {
    @EnvironmentObject private var store: GameStore
    @State private var tab: AppTab = .home
    @State private var showSettings = false
    @State private var path = NavigationPath()

    var body: some View {
        ZStack {
            AppBackgroundView()

            Group {
                switch tab {
                case .home:
                    NavigationStack(path: $path) {
                        HomeView(path: $path, onSettings: { showSettings = true })
                            .navigationDestination(for: ArenaType.self) { arena in
                                SlotGameView(arena: arena)
                            }
                            .navigationDestination(for: HomeRoute.self) { route in
                                switch route {
                                case .arenas:
                                    ArenaSelectView(path: $path)
                                }
                            }
                    }
                case .rewards:
                    NavigationStack {
                        RewardsView(onSettings: { showSettings = true })
                    }
                case .profile:
                    NavigationStack {
                        ProfileView(onSettings: { showSettings = true })
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            VStack(spacing: 0) {
                DisclaimerBanner()
                CustomTabBar(tab: $tab)
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .environmentObject(store)
        }
        .preferredColorScheme(.dark)
    }
}

enum HomeRoute: Hashable {
    case arenas
}

struct CustomTabBar: View {
    @Binding var tab: AppTab

    var body: some View {
        HStack {
            tabItem(.home, title: "Home", icon: "house.fill")
            tabItem(.rewards, title: "Rewards", icon: "gift.fill")
            tabItem(.profile, title: "Profile", icon: "person.fill")
        }
        .padding(.horizontal, 8)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(
            Rectangle()
                .fill(Color.black.opacity(0.82))
                .overlay(Divider().background(AppTheme.gold.opacity(0.35)), alignment: .top)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabItem(_ value: AppTab, title: String, icon: String) -> some View {
        let selected = tab == value
        return Button {
            tab = value
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.system(size: 11, weight: selected ? .bold : .medium))
            }
            .foregroundStyle(selected ? AppTheme.gold : AppTheme.textMuted)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(selected ? AppTheme.gold.opacity(0.12) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}
