import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: AppStore
    @Binding var selectedTab: Int

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)

        switch hour {
        case 5..<12: return "Guten Morgen"
        case 12..<18: return "Guten Tag"
        default: return "Guten Abend"
        }
    }

    private var progress: Double {
        guard !store.routines.isEmpty else { return 0 }
        return Double(store.completedToday) / Double(store.routines.count)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuminaBackground()

                ScrollView {
                    VStack(spacing: 22) {
                        header
                        heroCard
                        quickActions
                        routinesPreview
                    }
                    .luminaScreenPadding()
                    .padding(.vertical, 18)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(greeting), \(store.displayName)")
                    .font(.title.bold())

                Text(Date.now.formatted(
                    .dateTime.weekday(.wide).day().month(.wide)
                ))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .textCase(nil)
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 46, height: 46)

                Text(String(store.displayName.prefix(1)).uppercased())
                    .fontWeight(.bold)
                    .foregroundStyle(.luminaPurple)
            }
        }
    }

    private var heroCard: some View {
        GlassCard(padding: 22) {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(.primary.opacity(0.08), lineWidth: 10)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [.luminaPurple, .luminaBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.spring, value: progress)

                    Text("\(Int(progress * 100)) %")
                        .font(.headline.bold())
                }
                .frame(width: 92, height: 92)

                VStack(alignment: .leading, spacing: 7) {
                    Text("Dein heutiger Flow")
                        .font(.headline)

                    Text(
                        store.routines.isEmpty
                        ? "Füge deine erste Routine hinzu."
                        : "\(store.completedToday) von \(store.routines.count) Routinen geschafft"
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    Label(
                        "\(store.focusMinutesToday) Min. Fokus",
                        systemImage: "timer"
                    )
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.luminaPurple)
                }
            }
        }
    }

    private var quickActions: some View {
        HStack(spacing: 12) {
            Button {
                selectedTab = 2
            } label: {
                quickAction(
                    title: "Fokus starten",
                    icon: "play.fill",
                    colors: [.luminaPurple, .luminaBlue]
                )
            }
            .buttonStyle(.plain)

            Button {
                selectedTab = 1
            } label: {
                quickAction(
                    title: "Routine planen",
                    icon: "plus",
                    colors: [.mint, .teal]
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func quickAction(
        title: String,
        icon: String,
        colors: [Color]
    ) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background {
                    RoundedRectangle(cornerRadius: 13)
                        .fill(LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                }

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(17)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.3), lineWidth: 0.8)
        }
    }

    private var routinesPreview: some View {
        VStack(spacing: 13) {
            HStack {
                Text("Heute für dich")
                    .font(.title3.bold())

                Spacer()

                Button("Alle") { selectedTab = 1 }
                    .font(.subheadline)
            }

            if store.routines.isEmpty {
                GlassCard {
                    ContentUnavailableView(
                        "Noch keine Routinen",
                        systemImage: "checklist",
                        description: Text("Lege deine erste tägliche Routine an.")
                    )
                }
            } else {
                ForEach(store.routines.prefix(3)) { routine in
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            store.toggleRoutine(routine)
                        }
                    } label: {
                        HomeRoutineRow(routine: routine)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct HomeRoutineRow: View {
    @EnvironmentObject private var store: AppStore
    let routine: Routine

    var body: some View {
        let completed = routine.isCompleted(on: .now)

        GlassCard(padding: 14) {
            HStack(spacing: 13) {
                RoutineIcon(routine: routine)

                VStack(alignment: .leading, spacing: 4) {
                    Text(routine.title)
                        .font(.subheadline.weight(.semibold))
                        .strikethrough(completed)
                        .foregroundStyle(completed ? Color.secondary : Color.primary)

                    Text("\(routine.minutes) Minuten")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(completed ? Color.mint : Color.secondary.opacity(0.5))
            }
        }
    }
}
