import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: AppStore
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if store.hasCompletedOnboarding {
                mainApp
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: store.hasCompletedOnboarding)
    }

    private var mainApp: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Heute", systemImage: "sparkles")
                }
                .tag(0)

            RoutinesView()
                .tabItem {
                    Label("Routinen", systemImage: "checklist")
                }
                .tag(1)

            FocusView()
                .tabItem {
                    Label("Fokus", systemImage: "timer")
                }
                .tag(2)

            StatisticsView()
                .tabItem {
                    Label("Statistik", systemImage: "chart.bar.fill")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Profil", systemImage: "person.crop.circle")
                }
                .tag(4)
        }
        .tint(.luminaPurple)
        .onChange(of: selectedTab) { _, _ in
            store.playSelectionHaptic()
        }
    }
}
