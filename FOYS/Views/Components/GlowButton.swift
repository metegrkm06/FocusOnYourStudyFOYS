import SwiftUI

/// Neon Işıltılı Modern Buton
public struct GlowButton: View {
    public let title: String
    public let icon: String?
    public let gradientColors: [Color]
    public let height: CGFloat
    public let isLoading: Bool
    public let action: () -> Void

    public init(
        title: String,
        icon: String? = nil,
        gradientColors: [Color] = [Color(red: 0.0, green: 0.96, blue: 0.61), Color(red: 0.0, green: 0.82, blue: 1.0)],
        height: CGFloat = 54,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.gradientColors = gradientColors
        self.height = height
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: {
            HapticService.shared.tap()
            action()
        }) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 17, weight: .bold))
                    }
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: gradientColors.first?.opacity(0.4) ?? .clear, radius: 10, x: 0, y: 5)
        }
        .disabled(isLoading)
    }
}
