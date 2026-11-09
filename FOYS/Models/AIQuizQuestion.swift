import Foundation

/// Yapay zekanın ders çalışma kanıtı ve seçilen konuya göre ürettiği çoktan seçmeli soru
public struct AIQuizQuestion: Identifiable, Codable, Sendable, Hashable {
    public let id: String
    public let questionText: String
    public let options: [String] // 4 seçenek: A, B, C, D
    public let correctIndex: Int  // 0, 1, 2, 3
    public let explanation: String

    public var selectedIndex: Int? = nil

    public init(
        id: String = UUID().uuidString,
        questionText: String,
        options: [String],
        correctIndex: Int,
        explanation: String,
        selectedIndex: Int? = nil
    ) {
        self.id = id
        self.questionText = questionText
        self.options = options
        self.correctIndex = correctIndex
        self.explanation = explanation
        self.selectedIndex = selectedIndex
    }

    public var isAnswered: Bool {
        selectedIndex != nil
    }

    public var isCorrect: Bool {
        guard let selected = selectedIndex else { return false }
        return selected == correctIndex
    }

    /// Şık harfi (0 -> A, 1 -> B, 2 -> C, 3 -> D)
    public static func optionLetter(for index: Int) -> String {
        switch index {
        case 0: return "A"
        case 1: return "B"
        case 2: return "C"
        case 3: return "D"
        default: return "\(index + 1)"
        }
    }
}

/// Sınav sonuç özeti ve ceza hesaplama kuralı
public struct QuizEvaluationResult: Codable, Sendable {
    public let totalQuestions: Int
    public let correctCount: Int
    public let wrongCount: Int
    public let penaltyMinutes: Int
    public let isFullyPassed: Bool
    public let feedbackMessage: String

    public init(questions: [AIQuizQuestion]) {
        self.totalQuestions = questions.count
        let correct = questions.filter { $0.isCorrect }.count
        self.correctCount = correct
        self.wrongCount = max(0, totalQuestions - correct)

        // Kullanıcının kuralı:
        // "3 tane soru hepsini doğru bilirsek izin vercek
        // ama gidip 1 yanlış varsa 15 dk dahada çalış dicek
        // 2 yanlış ise 30dk 3 yanlış ise 50 dk daha çalış dicek"
        switch self.wrongCount {
        case 0:
            self.penaltyMinutes = 0
            self.isFullyPassed = true
            self.feedbackMessage = "Harika! 3/3 Tam Puan! 🎯 Ders çalışma kanıtın doğrulandı, tüm uygulamaların kilidi açıldı."
        case 1:
            self.penaltyMinutes = 15
            self.isFullyPassed = false
            self.feedbackMessage = "1 Yanlış! Konuyu tam kavramak için +15 Dakika daha odaklanman gerekiyor. Kilit uzatıldı!"
        case 2:
            self.penaltyMinutes = 30
            self.isFullyPassed = false
            self.feedbackMessage = "2 Yanlış! Konuda eksiklerin var, +30 Dakika daha çalışmalısın. Odaklanmaya devam et!"
        default:
            self.penaltyMinutes = 50
            self.isFullyPassed = false
            self.feedbackMessage = "3 Yanlış! Çalışma verimin düşük görünüyor. +50 Dakika derin çalışma cezası eklendi!"
        }
    }
}
