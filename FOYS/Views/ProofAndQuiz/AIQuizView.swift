import SwiftUI

/// 3 Soruluk Yapay Zeka Kilit Açma Sınavı Ekranı
public struct AIQuizView: View {
    @ObservedObject var sessionVM: StudySessionViewModel
    @ObservedObject var quizVM: AIQuizViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showingResult: Bool = false
    @State private var resultData: QuizEvaluationResult? = nil

    public init(sessionVM: StudySessionViewModel, quizVM: AIQuizViewModel) {
        self.sessionVM = sessionVM
        self.quizVM = quizVM
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.07, blue: 0.11).ignoresSafeArea()

                if let res = resultData {
                    QuizResultView(result: res) {
                        sessionVM.applyQuizResult(res)
                        dismiss()
                    }
                } else if let q = quizVM.currentQuestion {
                    VStack(spacing: 20) {
                        // 1. İlerleme Çubuğu ve Soru Sayacı
                        quizHeaderBar

                        // 2. Soru Kartı
                        questionCard(question: q)

                        // 3. Şıklar (A, B, C, D)
                        optionsList(question: q)

                        Spacer()

                        // 4. İleri / Geri veya Bitir Butonu
                        bottomNavigationButtons
                    }
                    .padding(20)
                } else {
                    ProgressView("Sorular hazırlanıyor...")
                        .foregroundColor(.white)
                }
            }
            .navigationTitle("Kilit Açma Sınavı")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - İlerleme Çubuğu & Başlık
    private var quizHeaderBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Soru \(quizVM.currentIndex + 1) / \(quizVM.questions.count)")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))

                Spacer()

                Text("\(sessionVM.currentSession.subject)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.gray)
            }

            // İlerleme Çizgisi
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.1))
                        .frame(height: 6)

                    let progress = Double(quizVM.currentIndex + 1) / Double(max(1, quizVM.questions.count))
                    Capsule().fill(Color(red: 0.0, green: 0.96, blue: 0.61))
                        .frame(width: geo.size.width * CGFloat(progress), height: 6)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: progress)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - Soru Kartı
    private func questionCard(question: AIQuizQuestion) -> some View {
        GlassContainer(cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 12) {
                Text(question.questionText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Şıklar Listesi
    private func optionsList(question: AIQuizQuestion) -> some View {
        VStack(spacing: 10) {
            ForEach(0..<question.options.count, id: \.self) { idx in
                let isSelected = question.selectedIndex == idx
                Button(action: {
                    quizVM.selectOption(at: idx)
                }) {
                    HStack(spacing: 14) {
                        Text(AIQuizQuestion.optionLetter(for: idx))
                            .font(.system(size: 14, weight: .black))
                            .foregroundColor(isSelected ? .black : Color(red: 0.0, green: 0.96, blue: 0.61))
                            .frame(width: 30, height: 30)
                            .background(
                                Circle().fill(isSelected ? Color(red: 0.0, green: 0.96, blue: 0.61) : Color.white.opacity(0.08))
                            )

                        Text(question.options[idx])
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isSelected ? Color(red: 0.0, green: 0.96, blue: 0.61) : .white)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                        }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(isSelected ? Color(red: 0.0, green: 0.96, blue: 0.61).opacity(0.12) : Color.white.opacity(0.04))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(isSelected ? Color(red: 0.0, green: 0.96, blue: 0.61) : Color.white.opacity(0.08), lineWidth: 1.5)
                    )
                }
            }
        }
    }

    // MARK: - Alt Gezinme & Bitir Butonları
    private var bottomNavigationButtons: some View {
        HStack(spacing: 12) {
            if quizVM.currentIndex > 0 {
                Button(action: {
                    quizVM.previousQuestion()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }

            if quizVM.isLastQuestion {
                GlowButton(
                    title: "Testi Bitir & Sonucu Gör",
                    icon: "flag.checkered",
                    gradientColors: [Color(red: 0.0, green: 0.96, blue: 0.61), Color(red: 0.0, green: 0.82, blue: 1.0)],
                    height: 50
                ) {
                    let result = quizVM.finishQuiz()
                    self.resultData = result
                }
                .disabled(!quizVM.allQuestionsAnswered)
                .opacity(quizVM.allQuestionsAnswered ? 1.0 : 0.5)
            } else {
                Button(action: {
                    quizVM.nextQuestion()
                }) {
                    HStack(spacing: 8) {
                        Text("Sonraki Soru")
                            .font(.system(size: 15, weight: .bold))
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0.0, green: 0.96, blue: 0.61))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .disabled(quizVM.currentQuestion?.selectedIndex == nil)
                .opacity(quizVM.currentQuestion?.selectedIndex != nil ? 1.0 : 0.5)
            }
        }
    }
}

/// Sınav Sonucu ve Ceza Bildirim Sayfası
public struct QuizResultView: View {
    public let result: QuizEvaluationResult
    public let onProceed: () -> Void

    public init(result: QuizEvaluationResult, onProceed: @escaping () -> Void) {
        self.result = result
        self.onProceed = onProceed
    }

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Büyük İkon
            ZStack {
                Circle()
                    .fill(result.isFullyPassed ? Color(red: 0.0, green: 0.96, blue: 0.61).opacity(0.18) : Color.red.opacity(0.18))
                    .frame(width: 100, height: 100)

                Image(systemName: result.isFullyPassed ? "checkmark.seal.fill" : "exclamationmark.octagon.fill")
                    .font(.system(size: 52))
                    .foregroundColor(result.isFullyPassed ? Color(red: 0.0, green: 0.96, blue: 0.61) : Color.red)
            }

            // Puan Başlığı
            VStack(spacing: 8) {
                Text("\(result.correctCount) / \(result.totalQuestions) Doğru")
                    .font(.system(size: 32, weight: .black, design: .monospaced))
                    .foregroundColor(.white)

                Text(result.isFullyPassed ? "TEBRİKLER! KİLİT AÇILDI" : "CEZA UYGULANDI")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(result.isFullyPassed ? Color(red: 0.0, green: 0.96, blue: 0.61) : Color.red)
                    .tracking(2)
            }

            // Ceza / Açıklama Kutusu
            GlassContainer(
                cornerRadius: 18,
                strokeColor: result.isFullyPassed ? Color(red: 0.0, green: 0.96, blue: 0.61).opacity(0.3) : Color.red.opacity(0.3),
                backgroundColor: result.isFullyPassed ? Color(red: 0.0, green: 0.96, blue: 0.61).opacity(0.08) : Color.red.opacity(0.08)
            ) {
                VStack(spacing: 10) {
                    if !result.isFullyPassed {
                        HStack(spacing: 8) {
                            Image(systemName: "timer")
                                .font(.system(size: 18, weight: .bold))
                            Text("+\(result.penaltyMinutes) Dakika Ek Ders Cezası")
                                .font(.system(size: 16, weight: .heavy))
                        }
                        .foregroundColor(.red)
                    }

                    Text(result.feedbackMessage)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(18)
            }
            .padding(.horizontal, 20)

            Spacer()

            // Devam Butonu
            GlowButton(
                title: result.isFullyPassed ? "Uygulamaları Aç & Tamamla" : "Cezayı Başlat (+\(result.penaltyMinutes) dk)",
                icon: result.isFullyPassed ? "lock.open.fill" : "flame.fill",
                gradientColors: result.isFullyPassed ?
                    [Color(red: 0.0, green: 0.96, blue: 0.61), Color(red: 0.0, green: 0.82, blue: 1.0)] :
                    [Color.orange, Color.red],
                height: 56
            ) {
                onProceed()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .padding(20)
    }
}
