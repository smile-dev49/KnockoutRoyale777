import SwiftUI

struct SplashView: View {
    let duration: TimeInterval

    @State private var contentOpacity: Double = 0
    @State private var contentScale: CGFloat = 0.86
    @State private var glowPulse = false
    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            AppBackgroundView()

            LinearGradient(
                colors: [
                    Color.black.opacity(0.25),
                    Color.black.opacity(0.55),
                    Color.black.opacity(0.72)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 22) {
                Spacer(minLength: 80)

                ZStack {
                    Circle()
                        .fill(AppTheme.gold.opacity(glowPulse ? 0.28 : 0.14))
                        .frame(width: 250, height: 250)
                        .blur(radius: 28)

                    Image("BrandIcon")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 196, height: 196)
                        .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 44, style: .continuous)
                                .stroke(AppTheme.goldGradient, lineWidth: 3)
                        )
                        .shadow(color: AppTheme.gold.opacity(0.45), radius: 18, y: 6)
                }
                .scaleEffect(contentScale)
                .opacity(contentOpacity)

                VStack(spacing: 8) {
                    Text("KNOCKOUT")
                        .font(.system(size: 34, weight: .black, design: .serif))
                        .foregroundStyle(AppTheme.goldGradient)
                        .shadow(color: AppTheme.gold.opacity(0.5), radius: 8)

                    Text("ROYALE  777")
                        .font(.system(size: 16, weight: .bold, design: .serif))
                        .foregroundStyle(AppTheme.goldLight)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(AppTheme.ruby.opacity(0.9)))
                        .overlay(Capsule().stroke(AppTheme.gold, lineWidth: 1.2))

                    Text("VIRTUAL ENTERTAINMENT")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppTheme.textMuted)
                        .tracking(1.4)
                        .padding(.top, 2)
                }
                .opacity(contentOpacity)

                Spacer()

                VStack(spacing: 12) {
                    ProgressView(value: progress)
                        .tint(AppTheme.gold)
                        .frame(width: 168)

                    Text("ENTERING THE ARENA…")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppTheme.textMuted)
                        .tracking(1.2)
                }
                .padding(.bottom, 48)
                .opacity(contentOpacity)
            }
            .padding(.horizontal, 24)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.spring(response: 0.75, dampingFraction: 0.82)) {
                contentScale = 1
                contentOpacity = 1
            }
            withAnimation(.easeInOut(duration: 1.35).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            withAnimation(.linear(duration: duration)) {
                progress = 1
            }
        }
    }
}
