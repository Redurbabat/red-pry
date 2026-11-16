import SwiftUI

struct Routine: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var symbol: String
    var minutes: Int
    var tint: RoutineTint
    var completedDates: Set<Date> = []

    func isCompleted(on date: Date, calendar: Calendar = .current) -> Bool {
        completedDates.contains {
            calendar.isDate($0, inSameDayAs: date)
        }
    }
}

enum RoutineTint: String, Codable, CaseIterable, Identifiable {
    case purple, blue, mint, orange, pink

    var id: String { rawValue }

    var colors: [Color] {
        switch self {
        case .purple:
            return [Color(red: 0.63, green: 0.43, blue: 1), .indigo]
        case .blue:
            return [.cyan, .blue]
        case .mint:
            return [.mint, .teal]
        case .orange:
            return [.yellow, .orange]
        case .pink:
            return [.pink, .purple]
        }
    }
}

struct FocusSession: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var minutes: Int
}

enum AppAppearance: String, Codable, CaseIterable, Identifiable {
    case system = "System"
    case light = "Hell"
    case dark = "Dunkel"

    var id: String { rawValue }
}
