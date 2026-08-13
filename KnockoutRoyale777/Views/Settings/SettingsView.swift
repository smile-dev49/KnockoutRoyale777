import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: GameStore
    @Environment(\.dismiss) private var dismiss

    @State private var nameDraft = ""
    @State private var showResetConfirm = false
    @State private var showResetDone = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    Color.clear.frame(height: 210)

                    settingsCard("Gameplay") {
                        toggleRow("Haptics", preference(\.hapticsEnabled))
                        toggleRow("Start with Turbo", preference(\.defaultTurboEnabled))
                        toggleRow("Confirm Max Bet", preference(\.confirmMaxBet))
                        toggleRow("Stop Auto on Big Win", preference(\.stopAutoOnBigWin))
                    }

                    settingsCard("Display") {
                        toggleRow("Keep Screen On", preference(\.keepScreenOn))
                        toggleRow("Reduce Motion", preference(\.reduceMotionInGame))
                    }

                    settingsCard("Player") {
                        HStack {
                            Text("Display Name")
                                .foregroundStyle(AppTheme.textSecondary)
                            Spacer()
                            TextField("Name", text: $nameDraft)
                                .multilineTextAlignment(.trailing)
                                .textInputAutocapitalization(.words)
                                .submitLabel(.done)
                                .foregroundStyle(AppTheme.goldLight)
                                .onSubmit { saveName() }
                                .frame(maxWidth: 150)
                        }
                        Button("Save Name") { saveName() }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppTheme.gold)
                        infoRow("Level", "\(store.level)")
                        infoRow("Balance", CoinFormat.string(store.coins))
                        infoRow("VIP", store.isVIP ? "Yes" : "No (reach level 20)")
                    }

                    settingsCard("Data") {
                        Button(role: .destructive) {
                            showResetConfirm = true
                        } label: {
                            Text("Reset Local Progress")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Text("Removes coins, level, missions, and achievements stored on this device. Settings preferences are kept.")
                            .font(.footnote)
                            .foregroundStyle(AppTheme.textMuted)
                    }

                    settingsCard("Virtual Currency") {
                        Text("All coins are virtual and have no real-world value. This game is for entertainment only. There is no cashout, wagering of real money, or prize redemption.")
                            .font(.footnote)
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    settingsCard("Paytable (3-of-a-kind)") {
                        ForEach(SlotSymbol.allCases) { symbol in
                            infoRow(symbol.displayName, "×\(Int(symbol.triplePayout)) bet")
                        }
                    }

                    settingsCard("About") {
                        infoRow("App", "Knockout Royale 777")
                        infoRow("Version", "1.0.0")
                        infoRow("Mode", "Offline / Local")
                    }

                    Button {
                        dismiss()
                    } label: {
                        Text("Close")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(AppTheme.goldLight)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Capsule().fill(AppTheme.ruby.opacity(0.85)))
                            .overlay(Capsule().stroke(AppTheme.gold.opacity(0.8), lineWidth: 1.2))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 4)
                    .padding(.bottom, 28)
                }
                .padding(.horizontal, 18)
            }
            .appScreenBackground()
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SETTINGS")
                        .font(.system(size: 16, weight: .black, design: .serif))
                        .foregroundStyle(AppTheme.goldGradient)
                }
            }
            .onAppear { nameDraft = store.displayName }
            .alert("Reset Progress?", isPresented: $showResetConfirm) {
                Button("Reset", role: .destructive) {
                    store.resetLocalProgress()
                    nameDraft = store.displayName
                    showResetDone = true
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently clears your local entertainment progress on this device. Virtual coins have no real-world value.")
            }
            .alert("Progress Reset", isPresented: $showResetDone) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your local progress was cleared. Starting coins have been restored.")
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func settingsCard<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold, design: .serif))
                .foregroundStyle(AppTheme.gold)
                .tracking(1.1)

            VStack(alignment: .leading, spacing: 12) {
                content()
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.58))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.gold.opacity(0.45), lineWidth: 1)
                )
        )
    }

    private func toggleRow(_ title: String, _ binding: Binding<Bool>) -> some View {
        Toggle(isOn: binding) {
            Text(title)
                .foregroundStyle(AppTheme.textPrimary)
        }
        .tint(AppTheme.gold)
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(AppTheme.textSecondary)
            Spacer()
            Text(value)
                .foregroundStyle(AppTheme.goldLight)
                .multilineTextAlignment(.trailing)
        }
        .font(.system(size: 15, weight: .medium))
    }

    private func preference(_ keyPath: ReferenceWritableKeyPath<GameStore, Bool>) -> Binding<Bool> {
        Binding(
            get: { store[keyPath: keyPath] },
            set: { newValue in
                store[keyPath: keyPath] = newValue
                store.savePreferences()
            }
        )
    }

    private func saveName() {
        store.rename(nameDraft)
        nameDraft = store.displayName
    }
}
