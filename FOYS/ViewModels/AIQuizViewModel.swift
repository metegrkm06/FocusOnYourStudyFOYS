import SwiftUI
import Combine

/// Yapay Zeka Kilit Açma Testi (3 Soru) ViewModel'i
@MainActor
public final class AIQuizViewModel: ObservableObject {
    @Published public var questions: [AIQuizQuestion] = []
    @Published public var currentIndex: Int = 0
    @Published public var evaluationResult: QuizEvaluationResult? = nil
    @Published public var isAnalyzing: Bool = false
    @Published public var analysisStatusText: String = ""

    public init(questions: [AIQuizQuestion] = []) {
        self.questions = questions
    }

    public func setQuestions(_ list: [AIQuizQuestion]) {
        self.questions = list
        self.currentIndex = 0
        self.evaluationResult = nil
    }

    public var currentQuestion: AIQuizQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    public var isLastQuestion: Bool {
        currentIndex == questions.count - 1
    }

    public var allQuestionsAnswered: Bool {
        !questions.isEmpty && questions.allSatisfy { $0.isAnswered }
    }

    public func selectOption(at optionIndex: Int) {
        guard currentIndex < questions.count else { return }
        questions[currentIndex].selectedIndex = optionIndex
        HapticService.shared.selection()
    }

    public func nextQuestion() {
        if currentIndex < questions.count - 1 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentIndex += 1
            }
        }
    }

    public func previousQuestion() {
        if currentIndex > 0 {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                currentIndex -= 1
            }
        }
    }

    /// Tüm sorular tamamlandığında sonuçları hesapla ve cezayı belirle
    public func finishQuiz() -> QuizEvaluationResult {
        let result = QuizEvaluationResult(questions: questions)
        self.evaluationResult = result

        if result.isFullyPassed {
            HapticService.shared.quizSuccess()
        } else {
            HapticService.shared.quizFailure()
        }

        return result
    }
}
