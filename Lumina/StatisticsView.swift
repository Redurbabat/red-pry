import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject private var store: AppStore

    private var weekDays: [Date] {
        let calendar = Calendar.current

        return (0..<7).compactMap { offset in
            calendar.date(
                byAdding: .day,
                value: offset - 6,
                to: calendar.startOfDay(for: .now)
            )
        }
    }

    private var maximumMinutes: Int {
        max(weekDays.map(store.minutes(on:)).max() ?? 0, store.dailyGoal, 1)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LuminaBackground()

                ScrollView {
                    VStack(spacing: 22) {
                        HStack(spacing: 12) {
                            statisticCard(
                                value: "\(store.focusMinutesThisWeek)",
                                unit: "Min.",
                                title: "Diese Woche",
                                icon: "clock.fill",
                                color: .luminaPurple
                            )

                            statisticCard(
                                value: "\(store.currentStreak)",
                                unit: store.currentStreak == 1 ? "Tag" : "Tage",
                                title: "Fokus-Serie",
                                icon: "flame.fill",
                                color: .orange
                            )
                        }

                        GlassCard(padding: 20) {
                            VStack(alignment: .leading, spacing: 22) {
                                SectionHeading(
                                    title: "Deine letzten 7 Tage",
                                    subtitle: "Fokusminuten pro Tag"
                                )

                                HStack(alignment: .bottom, spacing: 10) {
                                    ForEach(weekDays, id: \.self) { date in
                                        let minutes = store.minutes(on: date)
                                        let height = CGFloat(minutes) /
                                            CGFloat(maximumMinutes) * 150

                                        VStack(spacing: 8) {
                                            Text(minutes > 0 ? "\(minutes)" : "")
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)

                                            RoundedRectangle(
                                                cornerRadius: 8,
                                                style: .continuous
                                            )
                                            .fill(
                                                minutes > 0
                                                ? AnyShapeStyle(LinearGradient(
                                                    colors: [.luminaPurple, .luminaBlue],
                                                    startPoint: .bottom,
                                                    endPoint: .top
                                                ))
                                                : AnyShapeStyle(Color.primary.opacity(0.07))
                                            )
                                            .frame(height: max(height, 8))
                                            .frame(maxWidth: .infinity)

                                            Text(date.formatted(
                                                .dateTime.weekday(.narrow)
                                            ))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                                .frame(height: 205, alignment: .bottom)
                            }
                        }

                        GlassCard {
                            VStack(alignment: .leading, spacing: 16) {
                                SectionHeading(
                                    title: "Tagesziel",
                                    subtitle: "\(store.focusMinutesToday) von \(store.dailyGoal) Minuten"
                                )

                                ProgressView(
                                    value: Double(store.focusMinutesToday),
                                    total: Double(store.dailyGoal)
                                )
                                .tint(.luminaPurple)

                                Text(
                                    store.focusMinutesToday >= store.dailyGoal
                                    ? "Ziel erreicht – starke Leistung!"
                                    : "Noch \(max(store.dailyGoal - store.focusMinutesToday, 0)) Minuten bis zu deinem Ziel."
                                )
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            }
                        }

                        GlassCard {
                            Label(
                                "Nur abgeschlossene Fokus-Sessions werden in der Statistik gezählt.",
                                systemImage: "info.circle"
                            )
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Statistik")
        }
    }

    private func statisticCard(
        value: String,
        unit: String,
        title: String,
        icon: String,
        color: Color
    ) -> some View {
        GlassCard(padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(color)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 32, weight: .bold, design: .rounded))

                    Text(unit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
