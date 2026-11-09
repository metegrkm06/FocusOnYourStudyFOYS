import SwiftUI
import Combine

/// Ders Çalışma Oturumu Ana Koordinatör ViewModel'i
@MainActor
public final class StudySessionViewModel: ObservableObject {
    public static let shared = StudySessionViewModel()

    @Published public var currentSession: StudySession = StudySession()
    @Published public var isSessionActive: Bool = false
    @Published public var isPaused: Bool = false

    // Modallar ve Sayfa Geçişleri
    @Published public var showStartSheet: Bool = false
    @Published public var showEmergencyModal: Bool = false
    @Published public var showProofModal: Bool = false
    @Published public var showQuizModal: Bool = false
    @Published public var showScreenSaver: Bool = false
    @Published public var toastMessage: String? = nil

    // AI İşlemleri
    @Published public var isGeneratingQuiz: Bool = false
    @Published public var proofImage: UIImage? = nil
    @Published public var aiNotesSummary: String = ""
    @Published public var currentQuizVM: AIQuizViewModel = AIQuizViewModel()

    private var sessionTimer: AnyCancellable?
    private let screenTime = ScreenTimeManager.shared
    private let notifications = NotificationService.shared
    private let settings = SettingsViewModel.shared

    public init() {
        // Önceden devam eden oturum varsa yükle
        loadPersistedSession()
    }

    // MARK: - Oturumu Başlat
    public func startSession(
        mode: StudyBlockMode,
        durationMinutes: Int,
        examType: ExamType,
        gradeLevel: String,
        subject: String,
        topic: String
    ) {
        let targetSeconds = (mode == .timed) ? durationMinutes * 60 : 0
        let newSession = StudySession(
            mode: mode,
            targetDurationSeconds: targetSeconds,
            startedAt: Date(),
            examType: examType,
            gradeLevel: gradeLevel,
            subject: subject,
            topic: topic,
            state: .active
        )

        self.currentSession = newSession
        self.isSessionActive = true
        self.isPaused = false
        self.proofImage = nil
        self.aiNotesSummary = ""

        // Dikkat dağıtıcı uygulamaları kilitle
        screenTime.enableShield()

        // Süreli mod ise bildirim planla
        if mode == .timed {
            notifications.scheduleSessionCompletedNotification(
                in: targetSeconds,
                subject: subject,
                topic: topic
            )
        }

        startTimer()
        persistSession()
        showToast("Odaklanma Başladı! 🎯 Uygulamalar kilitlendi.")
    }

    // MARK: - Süre Sayacı
    private func startTimer() {
        sessionTimer?.cancel()
        sessionTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.timerTick()
            }
    }

    private func timerTick() {
        guard isSessionActive, !isPaused else { return }

        // Acil durum izni aktifse
        if currentSession.state == .emergencyPass {
            if currentSession.emergencyPassSecondsRemaining > 0 {
                currentSession.emergencyPassSecondsRemaining -= 1
            } else {
                // Acil durum izni bitti, tekrar kilitle
                currentSession.state = .active
                screenTime.enableShield()
                showToast("3 dakikalık acil izin bitti! Uygulamalar tekrar kilitlendi.")
            }
            return
        }

        currentSession.elapsedSeconds += 1

        // Süreli modda hedefe ulaşıldı mı?
        if currentSession.mode == .timed && currentSession.isTargetCompleted {
            if currentSession.state == .active || currentSession.state == .penaltyLock {
                currentSession.state = .proofRequired
                HapticService.shared.quizSuccess()
                showToast("Ders süresi bitti! 🎉 Lütfen çalışma kanıtını yükle.")
                showProofModal = true
            }
        }
    }

    // MARK: - 3 Dakikalık Acil İzin (Emergency Pass)
    public func useEmergencyPass() {
        guard isSessionActive, currentSession.state != .emergencyPass else { return }

        currentSession.state = .emergencyPass
        currentSession.emergencyPassesUsed += 1
        currentSession.emergencyPassSecondsRemaining = 180

        screenTime.grantEmergencyPass(durationSeconds: 180) { [weak self] in
            guard let self = self else { return }
            self.currentSession.state = .active
            self.showEmergencyModal = false
            self.showToast("Acil izin süresi doldu! Uygulamalar tekrar kilitlendi.")
        }

        showEmergencyModal = true
        showToast("3 dakikalık acil izin başlatıldı! ⏳")
    }

    public func endEmergencyPassEarly() {
        guard currentSession.state == .emergencyPass else { return }
        currentSession.state = .active
        currentSession.emergencyPassSecondsRemaining = 0
        screenTime.enableShield()
        showEmergencyModal = false
        showToast("Acil izin sonlandırıldı, kilit aktif.")
    }

    // MARK: - Ders Bitirme & Kanıt Yükleme
    public func promptProofUpload() {
        showProofModal = true
    }

    public func submitProofImage(_ image: UIImage) async {
        self.proofImage = image
        self.isGeneratingQuiz = true

        // 1. AI ile fotoğrafı analiz et
        let verification = await AIService.shared.verifyStudyProof(
            image: image,
            examType: currentSession.examType,
            subject: currentSession.subject,
            topic: currentSession.topic,
            config: settings.config
        )
        self.aiNotesSummary = verification.notesSummary

        // 2. 3 Soruluk Kilit Açma Testi Üret
        let questions = await AIService.shared.generateQuizQuestions(
            image: image,
            examType: currentSession.examType,
            subject: currentSession.subject,
            topic: currentSession.topic,
            config: settings.config
        )

        self.isGeneratingQuiz = false
        self.currentSession.state = .quizPending
        self.showProofModal = false

        // Quiz ekranını aç
        self.currentQuizVM = AIQuizViewModel(questions: questions)
        self.showQuizModal = true
    }

    // MARK: - Sınav Sonucunu Değerlendir ve Ceza / Kilit Aç
    public func applyQuizResult(_ result: QuizEvaluationResult) {
        currentSession.quizScore = result.correctCount

        if result.isFullyPassed {
            // 3/3 DOĞRU -> TAM KİLİT AÇMA
            currentSession.state = .completed
            currentSession.endedAt = Date()
            isSessionActive = false
            sessionTimer?.cancel()

            // Tüm kalkanları kaldır
            screenTime.disableShield()
            notifications.cancelAllNotifications()

            // İstatistikleri kaydet
            settings.stats.recordSession(session: currentSession, isQuizPassed: true)
            settings.saveStats()
            clearPersistedSession()

            showToast("Tebrikler! 3/3 Tam Puan 🎉 Kilitler kaldırıldı!")
        } else {
            // YANLIŞ CEVAP(LAR) -> CEZA SÜRESİ EKLE
            // 1 Yanlış: +15 Dk | 2 Yanlış: +30 Dk | 3 Yanlış: +50 Dk
            let penaltyMins = result.penaltyMinutes
            currentSession.penaltyMinutesAdded += penaltyMins
            currentSession.penaltySeconds += penaltyMins * 60
            currentSession.state = .penaltyLock

            // Uygulamaları sıkı kilitte tut
            screenTime.enableShield()

            // Yeni bitiş süresi için bildirim ayarla
            notifications.scheduleSessionCompletedNotification(
                in: currentSession.remainingSeconds,
                subject: currentSession.subject,
                topic: currentSession.topic
            )

            HapticService.shared.penaltyApplied()
            showToast("\(result.wrongCount) Yanlış! +\(penaltyMins) Dakika ek kilit cezası uygulandı! ⚠️")
        }
    }

    // MARK: - Kalıcılık (Oturum Kapanırsa Devam Etsin)
    private func persistSession() {
        if let data = try? JSONEncoder().encode(currentSession) {
            UserDefaults.standard.set(data, forKey: "foys_active_session")
        }
    }

    private func loadPersistedSession() {
        if let data = UserDefaults.standard.data(forKey: "foys_active_session"),
           let saved = try? JSONDecoder().decode(StudySession.self, from: data),
           saved.state == .active || saved.state == .penaltyLock {
            self.currentSession = saved
            self.isSessionActive = true
            startTimer()
        }
    }

    private func clearPersistedSession() {
        UserDefaults.standard.removeObject(forKey: "foys_active_session")
    }

    public func showToast(_ message: String) {
        self.toastMessage = message
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if self.toastMessage == message {
                self.toastMessage = nil
            }
        }
    }
}
