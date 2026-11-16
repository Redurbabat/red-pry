import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: AppStore

    @State private var showResetAlert = false
    @State private var showAbout = false

    var body: some View {
        NavigationStack {
            ZStack {
                LuminaBackground()

                List {
                    Section {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(
                                        colors: [.luminaPurple, .luminaBlue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                                    .frame(width: 64, height: 64)

                                Text(String(store.displayName.prefix(1)).uppercased())
                                    .font(.title.bold())
                                    .foregroundStyle(.white)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(store.displayName)
                                    .font(.title3.bold())

                                Text("Lumina bleibt privat auf deinem iPhone.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    Section("Personalisierung") {
                        HStack {
                            Label("Name", systemImage: "person.fill")

                            TextField("Dein Name", text: $store.userName)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(.secondary)
                        }

                        Picker(
                            selection: Binding(
                                get: { store.appearance },
                                set: { store.appearance = $0 }
                            )
                        ) {
                            ForEach(AppAppearance.allCases) { appearance in
                                Text(appearance.rawValue).tag(appearance)
                            }
                        } label: {
                            Label("Darstellung", systemImage: "circle.lefthalf.filled")
                        }

                        Toggle(
                            isOn: $store.hapticsEnabled
                        ) {
                            Label("Haptisches Feedback", systemImage: "iphone.radiowaves.left.and.right")
                        }
                    }

                    Section("Fokus") {
                        Stepper(value: $store.dailyGoal, in: 10...480, step: 5) {
                            HStack {
                                Label("Tagesziel", systemImage: "target")
                                Spacer()
                                Text("\(store.dailyGoal) Min.")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Section("Über Lumina") {
                        Button {
                            showAbout = true
                        } label: {
                            Label("Datenschutz & Info", systemImage: "hand.raised.fill")
                        }

                        HStack {
                            Label("Version", systemImage: "info.circle")
                            Spacer()
                            Text("1.0.0")
                                .foregroundStyle(.secondary)
                        }
                    }

                    Section {
                        Button("Alle Daten zurücksetzen", role: .destructive) {
                            showResetAlert = true
                        }
                    } footer: {
                        Text("Löscht Routinen, Fokus-Sessions und deine persönlichen Einstellungen dauerhaft.")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Profil")
            .alert("Wirklich alles löschen?", isPresented: $showResetAlert) {
                Button("Abbrechen", role: .cancel) {}
                Button("Alles löschen", role: .destructive) {
                    store.resetAllData()
                }
            } message: {
                Text("Diese Aktion kann nicht rückgängig gemacht werden.")
            }
            .sheet(isPresented: $showAbout) {
                aboutView
                    .presentationDetents([.medium])
            }
        }
    }

    private var aboutView: some View {
        NavigationStack {
            ZStack {
                LuminaBackground()

                VStack(spacing: 22) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 55))
                        .foregroundStyle(Color.luminaPurple)

                    Text("Lumina")
                        .font(.largeTitle.bold())

                    Text("Lumina benötigt keinen Account und enthält keine Werbung oder Tracker. Routinen, Fokus-Sessions und Einstellungen werden ausschließlich lokal auf diesem iPhone gespeichert. Es werden keine Daten an einen Server übertragen.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)

                    Text("Version 1.0.0 · Native iOS-App")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(28)
            }
            .navigationTitle("Datenschutz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { showAbout = false }
                }
            }
        }
    }
}
