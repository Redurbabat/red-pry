import SwiftUI
import Combine

@MainActor
final class AppStore: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    @AppStorage("userName") var userName = ""
    @AppStorage("dailyGoal") var dailyGoal = 60
    @AppStorage("hapticsEnabled") var hapticsEnabled = true
    @AppStorage("appearance") private var appearanceRaw = AppAppearance.system.rawValue

    @Published private(set) var routines: [Routine] = [] {
        didSet { saveRoutines() }
    }

    @Published private(set) var sessions: [FocusSession] = [] {
        didSet { saveSessions() }
    }

    private let routinesKey = "lumina.routines"
    private let sessionsKey = "lumina.sessions"

    init() {
        loadData()

        if UserDefaults.standard.object(forKey: routinesKey) == nil {
            routines = [
                Routine(
                    title: "Morgens Wasser trinken",
                    symbol: "drop.fill",
                    minutes: 5,
                    tint: .blue
                ),
                Routine(
                    title: "Bewusst bewegen",
                    symbol: "figure.walk",
                    minutes: 20,
                    tint: .mint
                ),
                Routine(
                    title: "Ohne Handy lesen",
                    symbol: "book.fill",
                    minutes: 15,
                    tint: .purple
                )
            ]
        }
    }

    var appearance: AppAppearance {
        get { AppAppearance(rawValue: appearanceRaw) ?? .system }
        set { appearanceRaw = newValue.rawValue }
    }

    var colorScheme: ColorScheme? {
        switch appearance {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var displayName: String {
        let name = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "du" : name
    }

    func completeOnboarding(name: String) {
        userName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        hasCompletedOnboarding = true
    }

    func addRoutine(
        title: String,
        symbol: String,
        minutes: Int,
        tint: RoutineTint
    ) {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else { return }

        routines.append(
            Routine(
                title: cleanTitle,
                symbol: symbol,
                minutes: minutes,
                tint: tint
            )
        )
    }

    func toggleRoutine(_ routine: Routine, on date: Date = .now) {
        guard let index = routines.firstIndex(where: { $0.id == routine.id }) else { return }

        let day = Calendar.current.startOfDay(for: date)

        if let existing = routines[index].completedDates.first(where: {
            Calendar.current.isDate($0, inSameDayAs: day)
        }) {
            routines[index].completedDates.remove(existing)
        } else {
            routines[index].completedDates.insert(day)
            playSuccessHaptic()
        }
    }

    func deleteRoutines(at offsets: IndexSet) {
        routines.remove(atOffsets: offsets)
    }

    func saveFocusSession(minutes: Int) {
        guard minutes > 0 else { return }

        sessions.append(
            FocusSession(date: .now, minutes: minutes)
        )

        playSuccessHaptic()
    }

    var completedToday: Int {
        routines.filter { $0.isCompleted(on: .now) }.count
    }

    var focusMinutesToday: Int {
        sessions
            .filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.minutes }
    }

    var focusMinutesThisWeek: Int {
        guard let interval = Calendar.current.dateInterval(
            of: .weekOfYear,
            for: .now
        ) else { return 0 }

        return sessions
            .filter { interval.contains($0.date) }
            .reduce(0) { $0 + $1.minutes }
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        let days = Set(
            sessions.map { calendar.startOfDay(for: $0.date) }
        )

        var streak = 0
        var date = calendar.startOfDay(for: .now)

        // Ein noch nicht begonnener heutiger Tag unterbricht die Serie nicht.
        if !days.contains(date) {
            date = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        }

        while days.contains(date) {
            streak += 1
            guard let previous = calendar.date(
                byAdding: .day,
                value: -1,
                to: date
            ) else { break }
            date = previous
        }

        return streak
    }

    func minutes(on date: Date) -> Int {
        sessions
            .filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
            .reduce(0) { $0 + $1.minutes }
    }

    func resetAllData() {
        routines = []
        sessions = []
        userName = ""
        dailyGoal = 60
        hapticsEnabled = true
        appearance = .system
        for key in ["lumina.focus.duration", "lumina.focus.remaining", "lumina.focus.endTimestamp", "lumina.focus.isRunning"] {
            UserDefaults.standard.removeObject(forKey: key)
        }
        hasCompletedOnboarding = false
    }

    func playSelectionHaptic() {
        guard hapticsEnabled else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    private func playSuccessHaptic() {
        guard hapticsEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func loadData() {
        let decoder = JSONDecoder()

        if let data = UserDefaults.standard.data(forKey: routinesKey),
           let decoded = try? decoder.decode([Routine].self, from: data) {
            routines = decoded
        }

        if let data = UserDefaults.standard.data(forKey: sessionsKey),
           let decoded = try? decoder.decode([FocusSession].self, from: data) {
            sessions = decoded
        }
    }

    private func saveRoutines() {
        guard let data = try? JSONEncoder().encode(routines) else { return }
        UserDefaults.standard.set(data, forKey: routinesKey)
    }

    private func saveSessions() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        UserDefaults.standard.set(data, forKey: sessionsKey)
    }
}
