import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: GameStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("About") {
                    LabeledContent("App", value: "Knockout Royale 777")
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Mode", value: "Offline / Local")
                }

                Section("Virtual Currency") {
                    Text("All coins are virtual and have no real-world value. This game is for entertainment only. There is no cashout, wagering of real money, or prize redemption.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("Player") {
                    LabeledContent("Level", value: "\(store.level)")
                    LabeledContent("Balance", value: CoinFormat.string(store.coins))
                    LabeledContent("VIP", value: store.isVIP ? "Yes" : "No (reach level 20)")
                }

                Section("Paytable (3-of-a-kind)") {
                    ForEach(SlotSymbol.allCases) { symbol in
                        LabeledContent(symbol.displayName, value: "×\(Int(symbol.triplePayout)) bet")
                    }
                }

                Section {
                    Button("Close") { dismiss() }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }
}
