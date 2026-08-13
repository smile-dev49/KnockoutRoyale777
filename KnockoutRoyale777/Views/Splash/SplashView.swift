import SwiftUI

struct SplashView: View {
    let duration: TimeInterval

    @State private var logoScale: CGFloat = 0.82
    @State private var logoOpacity: Double = 0
    @State private var glowPulse = false
    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            Circle()
                .fill(AppTheme.ruby.opacity(0.22))
                .frame(width: 320, height: 320)
                .blur(radius: 50)
                .scaleEffect(glowPulse ? 1.08 : 0.92)
                .offset(y: -40)

            Circle()
                .fill(AppTheme.gold.opacity(0.12))
                .frame(width: 220, height: 220)
                .blur(radius: 36)
                .scaleEffect(glowPulse ? 1.12 : 0.95)
                .offset(y: 20)

            VStack(spacing: 28) {
                Spacer()

                VStack(spacing: 14) {
                    HStack(spacing: -10) {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 58))
                            .foregroundStyle(AppTheme.ruby)
                            .rotationEffect(.degrees(-25))
                            .shadow(color: AppTheme.ruby.opacity(0.65), radius: 14)
                        Image(systemName: "sparkle")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(AppTheme.goldLight)
                            .offset(y: -12)
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 58))
                            .foregroundStyle(Color.black)
                            .rotationEffect(.degrees(25))
                            .shadow(color: AppTheme.gold.opacity(0.55), radius: 14)
                    }

                    HStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { _ in
                            Text("7")
                                .font(.system(size: 30, weight: .black, design: .rounded))
                                .foregroundStyle(AppTheme.ruby)
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(AppTheme.gold.opacity(0.18))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                .stroke(AppTheme.gold, lineWidth: 1.5)
                                        )
                                )
                        }
                    }

                    Text("KNOCKOUT")
                        .font(.system(size: 40, weight: .black, design: .serif))
                        .foregroundStyle(AppTheme.goldGradient)
                        .shadow(color: AppTheme.gold.opacity(0.55), radius: 10)

                    Text("ROYALE  777")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                        .foregroundStyle(AppTheme.goldLight)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 7)
                        .background(Capsule().fill(AppTheme.ruby.opacity(0.9)))
                        .overlay(Capsule().stroke(AppTheme.gold, lineWidth: 1.2))
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

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
                .opacity(logoOpacity)
            }
            .padding(.horizontal, 24)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                logoScale = 1
                logoOpacity = 1
            }
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                glowPulse = true
            }
            withAnimation(.linear(duration: duration)) {
                progress = 1
            }
        }
    }
}
