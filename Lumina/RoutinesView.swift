import SwiftUI

struct RoutinesView: View {
    @EnvironmentObject private var store: AppStore
    @State private var showAddRoutine = false

    var body: some View {
        NavigationStack {
            ZStack {
                LuminaBackground()

                Group {
                    if store.routines.isEmpty {
                        ContentUnavailableView {
                            Label("Deine Routinen", systemImage: "checklist")
                        } description: {
                            Text("Beginne mit einer kleinen Gewohnheit, die du jeden Tag schaffen kannst.")
                        } actions: {
                            Button("Erste Routine erstellen") {
                                showAddRoutine = true
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.luminaPurple)
                        }
                    } else {
                        List {
                            Section {
                                ForEach(store.routines) { routine in
                                    Button {
                                        withAnimation {
                                            store.toggleRoutine(routine)
                                        }
                                    } label: {
                                        RoutineListRow(routine: routine)
                                    }
                                    .buttonStyle(.plain)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                }
                                .onDelete(perform: store.deleteRoutines)
                            } footer: {
                                Text("Tippe auf eine Routine, um sie für heute abzuhaken. Wische zum Löschen nach links.")
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                }
            }
            .navigationTitle("Routinen")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddRoutine = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddRoutine) {
                AddRoutineView()
            }
        }
    }
}

struct RoutineListRow: View {
    let routine: Routine
    let completed: Bool

    init(routine: Routine) {
        self.routine = routine
        self.completed = routine.isCompleted(on: .now)
    }

    var body: some View {
        HStack(spacing: 14) {
            RoutineIcon(routine: routine)

            VStack(alignment: .leading, spacing: 4) {
                Text(routine.title)
                    .foregroundStyle(.primary)
                    .fontWeight(.medium)

                Text("\(routine.minutes) Min. · Täglich")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(completed ? .mint : .secondary)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(.white.opacity(0.3), lineWidth: 0.8)
        }
        .padding(.vertical, 4)
    }
}

struct AddRoutineView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var minutes = 15
    @State private var tint = RoutineTint.purple
    @State private var symbol = "sparkles"

    private let symbols = [
        "sparkles", "drop.fill", "book.fill", "figure.walk",
        "heart.fill", "moon.fill", "pencil", "brain.head.profile"
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LuminaBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 18) {
                                Text("Name")
                                    .font(.headline)

                                TextField("z. B. 10 Seiten lesen", text: $title)
                                    .padding(14)
                                    .background(
                                        Color(uiColor: .secondarySystemGroupedBackground).opacity(0.45),
                                        in: RoundedRectangle(cornerRadius: 14)
                                    )

                                Stepper(value: $minutes, in: 1...240) {
                                    HStack {
                                        Text("Dauer")
                                        Spacer()
                                        Text("\(minutes) Min.")
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Symbol")
                                    .font(.headline)

                                LazyVGrid(
                                    columns: Array(
                                        repeating: GridItem(.flexible()),
                                        count: 4
                                    ),
                                    spacing: 14
                                ) {
                                    ForEach(symbols, id: \.self) { item in
                                        Button {
                                            symbol = item
                                        } label: {
                                            Image(systemName: item)
                                                .font(.title3)
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 48)
                                                .foregroundStyle(
                                                    symbol == item ? Color.white : Color.primary
                                                )
                                                .background {
                                                    RoundedRectangle(cornerRadius: 14)
                                                        .fill(
                                                            symbol == item
                                                            ? Color.luminaPurple
                                                            : Color.primary.opacity(0.06)
                                                        )
                                                }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Farbe")
                                    .font(.headline)

                                HStack(spacing: 16) {
                                    ForEach(RoutineTint.allCases) { item in
                                        Button {
                                            tint = item
                                        } label: {
                                            Circle()
                                                .fill(LinearGradient(
                                                    colors: item.colors,
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ))
                                                .frame(width: 40, height: 40)
                                                .overlay {
                                                    if tint == item {
                                                        Image(systemName: "checkmark")
                                                            .foregroundStyle(.white)
                                                            .fontWeight(.bold)
                                                    }
                                                }
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        PrimaryGlassButton(
                            title: "Routine hinzufügen",
                            systemImage: "plus",
                            isDisabled: title.trimmingCharacters(
                                in: .whitespacesAndNewlines
                            ).isEmpty
                        ) {
                            store.addRoutine(
                                title: title,
                                symbol: symbol,
                                minutes: minutes,
                                tint: tint
                            )
                            dismiss()
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Neue Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
        }
    }
}
