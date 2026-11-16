import SwiftUI

extension Color {
    static let luminaPurple = Color(red: 0.62, green: 0.43, blue: 1)
    static let luminaBlue = Color(red: 0.25, green: 0.62, blue: 1)
}

struct LuminaBackground: View {
    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            Circle()
                .fill(Color.luminaPurple.opacity(0.35))
                .frame(width: 330, height: 330)
                .blur(radius: 40)
                .offset(x: -130, y: -350)

            Circle()
                .fill(Color.luminaBlue.opacity(0.3))
                .frame(width: 320, height: 320)
                .blur(radius: 50)
                .offset(x: 170, y: -120)

            Circle()
                .fill(Color.pink.opacity(0.18))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: -140, y: 360)
        }
        .ignoresSafeArea()
    }
}

struct GlassCard<Content: View>: View {
    var padding: CGFloat = 18
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.13),
                                        .white.opacity(0.02)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.5),
                                        .white.opacity(0.08)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.8
                            )
                    }
                    .shadow(color: .black.opacity(0.09), radius: 20, y: 10)
            }
    }
}

struct PrimaryGlassButton: View {
    let title: String
    var systemImage: String? = nil
    var isDisabled = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                if let systemImage {
                    Image(systemName: systemImage)
                }

                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundStyle(.white)
            .background {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: isDisabled
                                ? [.gray.opacity(0.5), .gray.opacity(0.35)]
                                : [.luminaPurple, .luminaBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay {
                        Capsule()
                            .stroke(.white.opacity(0.35), lineWidth: 1)
                    }
                    .shadow(
                        color: .luminaPurple.opacity(isDisabled ? 0 : 0.35),
                        radius: 16,
                        y: 8
                    )
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

struct SectionHeading: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title2.bold())

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RoutineIcon: View {
    let routine: Routine
    var size: CGFloat = 48

    var body: some View {
        Image(systemName: routine.symbol)
            .font(.system(size: size * 0.38, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background {
                RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: routine.tint.colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay {
                        RoundedRectangle(
                            cornerRadius: size * 0.32,
                            style: .continuous
                        )
                        .stroke(.white.opacity(0.4), lineWidth: 0.8)
                    }
            }
    }
}

extension View {
    func luminaScreenPadding() -> some View {
        padding(.horizontal, 20)
    }
}
