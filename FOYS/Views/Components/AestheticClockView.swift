import SwiftUI

/// Masa Saati Dijital Gösterge Bileşeni
public struct AestheticClockView: View {
    public let timeString: String
    public let fontSize: CGFloat

    public init(timeString: String, fontSize: CGFloat = 64) {
        self.timeString = timeString
        self.fontSize = fontSize
    }

    public var body: some View {
        HStack(spacing: 6) {
            let components = timeString.split(separator: ":")
            ForEach(0..<components.count, id: \.self) { idx in
                if idx > 0 {
                    Text(":")
                        .font(.system(size: fontSize * 0.8, weight: .black, design: .monospaced))
                        .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                        .opacity(0.8)
                }

                Text(String(components[idx]))
                    .font(.system(size: fontSize, weight: .heavy, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color(red: 0.07, green: 0.10, blue: 0.15))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            }
        }
    }
}
