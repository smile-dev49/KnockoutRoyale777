import SwiftUI

struct SplashView: View {
    let duration: TimeInterval

    @State private var contentOpacity: Double = 0
    @State private var contentScale: CGFloat = 0.92
    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            AppBackgroundView()

            // Soft veil so title/progress stay readable over the art.
            LinearGradient(
                colors: [
                    Color.black.opacity(0.15),
                    Color.black.opacity(0.45),
                    Color.black.opacity(0.62)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 18) {
                Spacer(minLength: 220)

                VStack(spacing: 10) {
                    Text("KNOCKOUT")
                        .font(.system(size: 38, weight: .black, design: .serif))
                        .foregroundStyle(AppTheme.goldGradient)
                        .shadow(color: AppTheme.gold.opacity(0.55), radius: 10)

                    Text("ROYALE  777")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundStyle(AppTheme.goldLight)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(AppTheme.ruby.opacity(0.9)))
                        .overlay(Capsule().stroke(AppTheme.gold, lineWidth: 1.2))

                    Text("VIRTUAL ENTERTAINMENT")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(AppTheme.textMuted)
                        .tracking(1.4)
                        .padding(.top, 4)
                }
                .scaleEffect(contentScale)
                .opacity(contentOpacity)

                Spacer()

                VStack(spacing: 12) {
                    ProgressView(value: progress)
                        .tint(AppTheme.gold)
                        .frame(width: 160)

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
            withAnimation(.easeOut(duration: 0.7)) {
                contentScale = 1
                contentOpacity = 1
            }
            withAnimation(.linear(duration: duration)) {
                progress = 1
            }
        }
    }
}
