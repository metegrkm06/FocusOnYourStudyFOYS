import SwiftUI

/// Dairesel İlerleme ve Geri Sayım Halkası
public struct CircularProgressRing: View {
    public let progress: Double
    public let timeText: String
    public let statusText: String
    public let ringColor: Color
    public let lineWidth: CGFloat
    public let size: CGFloat

    public init(
        progress: Double,
        timeText: String,
        statusText: String,
        ringColor: Color = Color(red: 0.0, green: 0.96, blue: 0.61),
        lineWidth: CGFloat = 16,
        size: CGFloat = 260
    ) {
        self.progress = progress
        self.timeText = timeText
        self.statusText = statusText
        self.ringColor = ringColor
        self.lineWidth = lineWidth
        self.size = size
    }

    public var body: some View {
        ZStack {
            // Arka plan mat halka
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: lineWidth)
                .frame(width: size, height: size)

            // İlerleme halkası
            Circle()
                .trim(from: 0, to: CGFloat(max(0.001, min(progress, 1.0))))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [ringColor.opacity(0.6), ringColor, ringColor]),
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: progress)
                .shadow(color: ringColor.opacity(0.35), radius: 10, x: 0, y: 0)

            // İçerik
            VStack(spacing: 6) {
                Text(timeText)
                    .font(.system(size: size * 0.16, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .contentTransition(.numericText())

                Text(statusText)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(ringColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(ringColor.opacity(0.15)))
            }
        }
    }
}
