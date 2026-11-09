import UIKit

/// FOYS Dokunsal Geri Bildirim Yöneticisi
public final class HapticService: @unchecked Sendable {
    public static let shared = HapticService()

    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    private let notificationFeedback = UINotificationFeedbackGenerator()

    private init() {
        lightImpact.prepare()
        mediumImpact.prepare()
        selectionFeedback.prepare()
    }

    public func tap() {
        lightImpact.impactOccurred()
    }

    public func selection() {
        selectionFeedback.selectionChanged()
    }

    public func sessionStarted() {
        heavyImpact.impactOccurred()
    }

    public func emergencyWarning() {
        mediumImpact.impactOccurred(intensity: 0.9)
    }

    public func quizSuccess() {
        notificationFeedback.notificationOccurred(.success)
    }

    public func quizFailure() {
        notificationFeedback.notificationOccurred(.error)
    }

    public func penaltyApplied() {
        heavyImpact.impactOccurred()
    }
}
