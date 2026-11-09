import Foundation

/// Çalışma oturumu modu (Süreli veya Süresiz)
public enum StudyBlockMode: String, CaseIterable, Identifiable, Codable, Sendable {
    case timed = "Süreli Odaklanma"
    case indefinite = "Süresiz Odaklanma"

    public var id: String { rawValue }

    public var description: String {
        switch self {
        case .timed:
            return "Belirlediğin süre boyunca tüm dikkat dağıtıcı uygulamalar kilitlenir. Süre bitince sınav / soru kilidi açılır."
        case .indefinite:
            return "Süre sınırı yok! Sen çalışmayı bitirip kanıtını yükleyip AI sorularını bilene kadar uygulamalar kapalı kalır."
        }
    }
}

/// Oturumun anlık durumu
public enum StudySessionState: String, Codable, Sendable {
    case idle           // Başlatılmadı
    case active         // Ders çalışma devam ediyor, uygulamalar kilitli
    case emergencyPass  // 3 dakikalık acil durum izni aktif
    case proofRequired  // Süre bitti veya bitir dendi, fotoğraf kanıtı bekleniyor
    case quizPending    // Fotoğraf yüklendi, 3 soruluk kilit testi çözülüyor
    case penaltyLock    // Soru(lar) yanlış yapıldı, ek süre cezası eklendi ve kilitlendi
    case completed      // Tüm sorular doğru bilindi ve başarıyla kilit açıldı
    case abandoned      // Kullanıcı pes etti / iptal etti
}

/// Aktif veya geçmiş ders çalışma oturumu modeli
public struct StudySession: Identifiable, Codable, Sendable {
    public let id: UUID
    public var mode: StudyBlockMode
    public var targetDurationSeconds: Int
    public var elapsedSeconds: Int
    public var penaltySeconds: Int
    public var startedAt: Date
    public var endedAt: Date?

    public var examType: ExamType
    public var gradeLevel: String
    public var subject: String
    public var topic: String

    public var state: StudySessionState

    // 3 dakikalık acil izin
    public var emergencyPassesUsed: Int
    public var emergencyPassSecondsRemaining: Int

    // Sınav sonucu
    public var quizScore: Int // 0, 1, 2, 3
    public var penaltyMinutesAdded: Int // 0, 15, 30, 50

    public init(
        id: UUID = UUID(),
        mode: StudyBlockMode = .timed,
        targetDurationSeconds: Int = 45 * 60, // Varsayılan 45 dakika
        elapsedSeconds: Int = 0,
        penaltySeconds: Int = 0,
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        examType: ExamType = .yksTyt,
        gradeLevel: String = "12. Sınıf",
        subject: String = "Temel Matematik",
        topic: String = "Problemler",
        state: StudySessionState = .idle,
        emergencyPassesUsed: Int = 0,
        emergencyPassSecondsRemaining: Int = 180,
        quizScore: Int = 0,
        penaltyMinutesAdded: Int = 0
    ) {
        self.id = id
        self.mode = mode
        self.targetDurationSeconds = targetDurationSeconds
        self.elapsedSeconds = elapsedSeconds
        self.penaltySeconds = penaltySeconds
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.examType = examType
        self.gradeLevel = gradeLevel
        self.subject = subject
        self.topic = topic
        self.state = state
        self.emergencyPassesUsed = emergencyPassesUsed
        self.emergencyPassSecondsRemaining = emergencyPassSecondsRemaining
        self.quizScore = quizScore
        self.penaltyMinutesAdded = penaltyMinutesAdded
    }

    /// Kalan toplam çalışma süresi (hedef + ceza - geçen)
    public var remainingSeconds: Int {
        if mode == .indefinite {
            return 0
        }
        let totalTarget = targetDurationSeconds + penaltySeconds
        return max(0, totalTarget - elapsedSeconds)
    }

    /// Süre tamamlandı mı?
    public var isTargetCompleted: Bool {
        if mode == .indefinite {
            return false
        }
        return remainingSeconds == 0
    }

    /// İlerleme yüzdesi (0.0 - 1.0)
    public var progress: Double {
        if mode == .indefinite {
            return min(Double(elapsedSeconds) / 3600.0, 1.0)
        }
        let totalTarget = targetDurationSeconds + penaltySeconds
        guard totalTarget > 0 else { return 1.0 }
        return min(Double(elapsedSeconds) / Double(totalTarget), 1.0)
    }

    /// Kalan sürenin HH:mm:ss veya mm:ss formatı
    public var formattedRemainingTime: String {
        let sec = remainingSeconds
        let hours = sec / 3600
        let minutes = (sec % 3600) / 60
        let seconds = sec % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    /// Geçen toplam çalışma süresi formatı
    public var formattedElapsedTime: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    /// Acil izin kalan süresi (örn: "02:45")
    public var formattedEmergencyTime: String {
        let minutes = emergencyPassSecondsRemaining / 60
        let seconds = emergencyPassSecondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
