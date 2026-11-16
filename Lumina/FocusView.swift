import SwiftUI

struct FocusView: View {
    @EnvironmentObject private var store: AppStore

    @State private var selectedMinutes = 25
    @State private var remainingSeconds = 25 * 60
    @State private var endDate: Date?
    @State private var isRunning = false
    @State private var showCompletion = false

    private let timer = Timer.publish(every: 0.25, on: .main, in: .common)
        .autoconnect()

    private var progress: Double {
        let total = Double(selectedMinutes * 60)
        guard total > 0 else { return 0 }
        return min(max(1 - Double(remainingSeconds) / total, 0), 1)
    }

    private var timeText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuminaBackground()

                VStack(spacing: 28) {
                    VStack(spacing: 7) {
                        Text("Fokusmodus")
                            .font(.largeTitle.bold())

                        Text(isRunning
                             ? "Bleib ganz bei dieser einen Sache."
                             : "Wähle deine Zeit und blende den Rest aus.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    }
                    .padding(.top)

                    if !isRunning {
                        Picker("Dauer", selection: $selectedMinutes) {
                            ForEach([5, 15, 25, 45, 60], id: \.self) { minutes in
                                Text("\(minutes) Min.").tag(minutes)
                            }
                        }
                        .pickerStyle(.segmented)
                        .disabled(isRunning)
                        .onChange(of: selectedMinutes) { _, newValue in
                            remainingSeconds = newValue * 60
                        }
                    }

                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 280, height: 280)
                            .overlay {
                                Circle()
                                    .stroke(.white.opacity(0.35), lineWidth: 1)
                            }
                            .shadow(
                                color: .luminaPurple.opacity(0.2),
                                radius: 35
                            )

                        Circle()
                            .stroke(.primary.opacity(0.07), lineWidth: 12)
                            .frame(width: 240, height: 240)

                        Circle()
                            .trim(from: 0, to: max(progress, 0.001))
                            .stroke(
                                LinearGradient(
                                    colors: [.luminaPurple, .luminaBlue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(
                                    lineWidth: 12,
                                    lineCap: .round
                                )
                            )
                            .frame(width: 240, height: 240)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.25), value: progress)

                        VStack(spacing: 8) {
                            Text(timeText)
                                .font(.system(
                                    size: 58,
                                    weight: .light,
                                    design: .rounded
                                ))
                                .monospacedDigit()
                                .contentTransition(.numericText())

                            Text(isRunning ? "FOKUS" : "BEREIT")
                                .font(.caption.weight(.semibold))
                                .tracking(3)
                                .foregroundStyle(.secondary)
                        }
                    }

                    VStack(spacing: 13) {
                        PrimaryGlassButton(
                            title: isRunning ? "Pausieren" : "Fokus starten",
                            systemImage: isRunning ? "pause.fill" : "play.fill"
                        ) {
                            isRunning ? pause() : start()
                        }

                        if isRunning || remainingSeconds != selectedMinutes * 60 {
                            Button("Zurücksetzen", role: .destructive) {
                                reset()
                            }
                        }
                    }

                    Text("Tipp: Aktiviere auf deinem iPhone eine Fokus-Umgebung, um Mitteilungen stummzuschalten.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(20)
            }
            .toolbar(.hidden, for: .navigationBar)
            .onReceive(timer) { _ in
                updateTimer()
            }
            .alert("Fokus geschafft!", isPresented: $showCompletion) {
                Button("Sehr gut") { reset() }
            } message: {
                Text("Du hast \(selectedMinutes) Minuten konzentriert gearbeitet. Deine Session wurde gespeichert.")
            }
        }
    }

    private func start() {
        if remainingSeconds <= 0 {
            remainingSeconds = selectedMinutes * 60
        }

        endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        isRunning = true
        store.playSelectionHaptic()
    }

    private func pause() {
        updateTimer()
        isRunning = false
        endDate = nil
    }

    private func reset() {
        isRunning = false
        endDate = nil
        remainingSeconds = selectedMinutes * 60
    }

    private func updateTimer() {
        guard isRunning, let endDate else { return }

        remainingSeconds = max(
            0,
            Int(ceil(endDate.timeIntervalSinceNow))
        )

        if remainingSeconds == 0 {
            isRunning = false
            self.endDate = nil
            store.saveFocusSession(minutes: selectedMinutes)
            showCompletion = true
        }
    }
}
