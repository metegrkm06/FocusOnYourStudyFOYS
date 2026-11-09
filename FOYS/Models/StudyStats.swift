import Foundation

/// Kullanıcının genel ders çalışma ve odaklanma istatistikleri
public struct StudyStats: Codable, Sendable {
    public var totalFocusedMinutes: Int
    public var totalSessionsCompleted: Int
    public var totalEmergencyPassesUsed: Int
    public var totalQuizzesTaken: Int
    public var totalQuizzesPassed: Int
    public var totalPenaltyMinutesServed: Int
    public var currentDayStreak: Int
    public var lastStudiedDate: Date?

    public init(
        totalFocusedMinutes: Int = 0,
        totalSessionsCompleted: Int = 0,
        totalEmergencyPassesUsed: Int = 0,
        totalQuizzesTaken: Int = 0,
        totalQuizzesPassed: Int = 0,
        totalPenaltyMinutesServed: Int = 0,
        currentDayStreak: Int = 0,
        lastStudiedDate: Date? = nil
    ) {
        self.totalFocusedMinutes = totalFocusedMinutes
        self.totalSessionsCompleted = totalSessionsCompleted
        self.totalEmergencyPassesUsed = totalEmergencyPassesUsed
        self.totalQuizzesTaken = totalQuizzesTaken
        self.totalQuizzesPassed = totalQuizzesPassed
        self.totalPenaltyMinutesServed = totalPenaltyMinutesServed
        self.currentDayStreak = currentDayStreak
        self.lastStudiedDate = lastStudiedDate
    }

    /// Başarı oranı yüzdesi
    public var quizSuccessRate: Double {
        guard totalQuizzesTaken > 0 else { return 100.0 }
        return (Double(totalQuizzesPassed) / Double(totalQuizzesTaken)) * 100.0
    }

    /// Saat formatı (örn: "24.5 Saat")
    public var formattedTotalHours: String {
        let hours = Double(totalFocusedMinutes) / 60.0
        return String(format: "%.1f Saat", hours)
    }

    /// Tamamlanan oturumu kaydet
    public mutating func recordSession(session: StudySession, isQuizPassed: Bool) {
        let minutes = session.elapsedSeconds / 60
        self.totalFocusedMinutes += minutes
        self.totalSessionsCompleted += 1
        self.totalEmergencyPassesUsed += session.emergencyPassesUsed
        self.totalPenaltyMinutesServed += session.penaltyMinutesAdded
        self.totalQuizzesTaken += 1
        if isQuizPassed {
            self.totalQuizzesPassed += 1
        }

        // Günlük streak güncellemesi
        let calendar = Calendar.current
        let today = Date()
        if let last = lastStudiedDate {
            if calendar.isDateInYesterday(last) {
                currentDayStreak += 1
            } else if !calendar.isDateInToday(last) {
                currentDayStreak = 1
            }
        } else {
            currentDayStreak = 1
        }
        self.lastStudiedDate = today
    }
}
