import SwiftUI

@main
struct LuminaApp: App {
    @StateObject private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(store.colorScheme)
        }
    }
}
