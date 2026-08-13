import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: GameStore
    @Environment(\.dismiss) private var dismiss

    @State private var nameDraft = ""
    @State private var showResetConfirm = false
    @State private var showResetDone = false

    var body: some View {
        NavigationStack {
            List {
                Section("Gameplay") {
                    Toggle("Haptics", isOn: preference(\.hapticsEnabled))
                    Toggle("Start with Turbo", isOn: preference(\.defaultTurboEnabled))
                    Toggle("Confirm Max Bet", isOn: preference(\.confirmMaxBet))
                    Toggle("Stop Auto on Big Win", isOn: preference(\.stopAutoOnBigWin))
                }

                Section("Display") {
                    Toggle("Keep Screen On", isOn: preference(\.keepScreenOn))
                    Toggle("Reduce Motion", isOn: preference(\.reduceMotionInGame))
                }

                Section("Player") {
                    HStack {
                        Text("Display Name")
                        Spacer()
                        TextField("Name", text: $nameDraft)
                            .multilineTextAlignment(.trailing)
                            .textInputAutocapitalization(.words)
                            .submitLabel(.done)
                            .onSubmit { saveName() }
                            .frame(maxWidth: 160)
                    }
                    Button("Save Name") { saveName() }
                    LabeledContent("Level", value: "\(store.level)")
                    LabeledContent("Balance", value: CoinFormat.string(store.coins))
                    LabeledContent("VIP", value: store.isVIP ? "Yes" : "No (reach level 20)")
                }

                Section("Data") {
                    Button("Reset Local Progress", role: .destructive) {
                        showResetConfirm = true
                    }
                    Text("Removes coins, level, missions, and achievements stored on this device. Settings preferences are kept.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Virtual Currency") {
                    Text("All coins are virtual and have no real-world value. This game is for entertainment only. There is no cashout, wagering of real money, or prize redemption.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Paytable (3-of-a-kind)") {
                    ForEach(SlotSymbol.allCases) { symbol in
                        LabeledContent(symbol.displayName, value: "×\(Int(symbol.triplePayout)) bet")
                    }
                }

                Section("About") {
                    LabeledContent("App", value: "Knockout Royale 777")
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Mode", value: "Offline / Local")
                }

                Section {
                    Button("Close") { dismiss() }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
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
