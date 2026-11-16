import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: AppStore

    @State private var page = 0
    @State private var name = ""

    var body: some View {
        ZStack {
            LuminaBackground()

            VStack(spacing: 24) {
                HStack {
                    Spacer()

                    if page < 2 {
                        Button("Überspringen") {
                            withAnimation { page = 2 }
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 30)

                TabView(selection: $page) {
                    welcomePage.tag(0)
                    focusPage.tag(1)
                    namePage.tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.45), value: page)

                HStack(spacing: 7) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(
                                index == page
                                ? Color.luminaPurple
                                : Color.primary.opacity(0.15)
                            )
                            .frame(width: index == page ? 25 : 7, height: 7)
                    }
                }

                PrimaryGlassButton(
                    title: page == 2 ? "Lumina starten" : "Weiter",
                    systemImage: page == 2 ? "sparkles" : "arrow.right"
                ) {
                    if page < 2 {
                        withAnimation { page += 1 }
                    } else {
                        store.completeOnboarding(name: name)
                    }
                }
            }
            .padding(24)
        }
    }

    private var welcomePage: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 160, height: 160)
                    .overlay {
                        Circle().stroke(.white.opacity(0.4), lineWidth: 1)
                    }
                    .shadow(color: .luminaPurple.opacity(0.25), radius: 30)

                Image(systemName: "sparkles")
                    .font(.system(size: 65, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.luminaPurple, .luminaBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 12) {
                Text("Dein Tag.\nIm richtigen Flow.")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)

                Text("Kleine Routinen, echte Fokuszeit und ein ruhigerer Kopf – alles an einem Ort.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()
        }
    }

    private var focusPage: some View {
        VStack(spacing: 28) {
            Spacer()

            GlassCard {
                VStack(spacing: 22) {
                    feature(
                        icon: "checkmark.circle.fill",
                        title: "Routinen, die bleiben",
                        text: "Plane einfache Gewohnheiten und hake sie täglich ab.",
                        color: .mint
                    )

                    feature(
                        icon: "timer",
                        title: "Fokus ohne Ablenkung",
                        text: "Arbeite mit einem klaren Timer an dem, was zählt.",
                        color: .luminaPurple
                    )

                    feature(
                        icon: "chart.bar.fill",
                        title: "Fortschritt sichtbar machen",
                        text: "Behalte deine Woche und deine Serien im Blick.",
                        color: .orange
                    )
                }
            }

            Text("Kein Account. Keine Werbung.\nDeine Daten bleiben auf deinem iPhone.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
    }

    private var namePage: some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: "person.crop.circle.badge.sparkles")
                .font(.system(size: 70))
                .foregroundStyle(.luminaPurple)

            VStack(spacing: 12) {
                Text("Wie dürfen wir dich nennen?")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text("Optional – du kannst den Namen später ändern.")
                    .foregroundStyle(.secondary)
            }

            TextField("Dein Name", text: $name)
                .textInputAutocapitalization(.words)
                .submitLabel(.done)
                .padding(17)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.white.opacity(0.35), lineWidth: 0.8)
                }

            Spacer()
        }
    }

    private func feature(
        icon: String,
        title: String,
        text: String,
        color: Color
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 34)

            VStack(alignment: .leading, spacing: 5) {
                Text(title).fontWeight(.semibold)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
