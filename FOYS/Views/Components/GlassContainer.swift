import SwiftUI

/// Frosted Glass / Saydam Şık Kart Bileşeni
public struct GlassContainer<Content: View>: View {
    public let cornerRadius: CGFloat
    public let strokeColor: Color
    public let backgroundColor: Color
    public let content: Content

    public init(
        cornerRadius: CGFloat = 20,
        strokeColor: Color = Color.white.opacity(0.12),
        backgroundColor: Color = Color(red: 0.08, green: 0.11, blue: 0.17).opacity(0.85),
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.strokeColor = strokeColor
        self.backgroundColor = backgroundColor
        self.content = content()
    }

    public var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(strokeColor, lineWidth: 1.2)
            )
    }
}
