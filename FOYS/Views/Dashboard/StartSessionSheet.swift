import SwiftUI

/// Yeni Ders Çalışma Oturumu Başlatma Sayfası
public struct StartSessionSheet: View {
    @ObservedObject var sessionVM: StudySessionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedMode: StudyBlockMode = .timed
    @State private var selectedExam: ExamType = .yksTyt
    @State private var selectedGrade: String = "12. Sınıf"
    @State private var selectedSubject: String = "Temel Matematik"
    @State private var topicText: String = "Problemler"
    @State private var durationMinutes: Double = 45.0

    public init(sessionVM: StudySessionViewModel) {
        self.sessionVM = sessionVM
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.07, blue: 0.11).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // 1. Bloklama Modu (Süreli vs Süresiz)
                        modeSelectorSection

                        // 2. Sınav ve Sınıf Seçimi
                        examAndGradeSection

                        // 3. Ders ve Konu Seçimi
                        subjectAndTopicSection

                        // 4. Süre Ayarı (Süreli mod ise)
                        if selectedMode == .timed {
                            durationPickerSection
                        }

                        // 5. Engellenecek Uygulama Hatırlatması
                        appBlockerNoticeCard

                        // 6. Başlat Butonu
                        GlowButton(
                            title: "Odaklanmayı Başlat & Kilitle",
                            icon: "lock.shield.fill",
                            gradientColors: [Color(red: 0.0, green: 0.96, blue: 0.61), Color(red: 0.0, green: 0.82, blue: 1.0)],
                            height: 56
                        ) {
                            sessionVM.startSession(
                                mode: selectedMode,
                                durationMinutes: Int(durationMinutes),
                                examType: selectedExam,
                                gradeLevel: selectedGrade,
                                subject: selectedSubject,
                                topic: topicText.isEmpty ? "Genel Çalışma" : topicText
                            )
                            dismiss()
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Yeni Çalışma Oturumu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
            }
            .onAppear {
                selectedGrade = selectedExam.defaultGradeLevels.first ?? "12. Sınıf"
                selectedSubject = selectedExam.defaultSubjects.first ?? "Matematik"
            }
            .onChange(of: selectedExam) { newExam in
                selectedGrade = newExam.defaultGradeLevels.first ?? "12. Sınıf"
                selectedSubject = newExam.defaultSubjects.first ?? "Matematik"
                let suggestions = StudyTopic.suggestedTopics(for: selectedSubject)
                topicText = suggestions.first ?? "Konu Tekrarı"
            }
            .onChange(of: selectedSubject) { newSubject in
                let suggestions = StudyTopic.suggestedTopics(for: newSubject)
                topicText = suggestions.first ?? "Konu Tekrarı"
            }
        }
    }

    // MARK: - Mod Seçimi (Süreli vs Süresiz)
    private var modeSelectorSection: some View {
        GlassContainer(cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Çalışma Modu")
                    .font(.caption.weight(.bold))
                    .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))

                HStack(spacing: 12) {
                    ForEach(StudyBlockMode.allCases) { mode in
                        Button(action: {
                            HapticService.shared.selection()
                            selectedMode = mode
                        }) {
                            VStack(spacing: 6) {
                                Image(systemName: mode == .timed ? "timer" : "infinity")
                                    .font(.system(size: 20, weight: .bold))
                                Text(mode.rawValue)
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(selectedMode == mode ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(selectedMode == mode ? Color(red: 0.0, green: 0.96, blue: 0.61) : Color.white.opacity(0.06))
                            )
                        }
                    }
                }

                Text(selectedMode.description)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            .padding(16)
        }
    }

    // MARK: - Sınav ve Sınıf Seçimi
    private var examAndGradeSection: some View {
        GlassContainer(cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Hedef Sınav ve Sınıf Düzeyi")
                    .font(.caption.weight(.bold))
                    .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))

                // Sınav Seçici
                Menu {
                    ForEach(ExamType.allCases) { exam in
                        Button(action: { selectedExam = exam }) {
                            Label(exam.rawValue, systemImage: exam.iconName)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: selectedExam.iconName)
                            .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                        Text(selectedExam.rawValue)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                // Sınıf / Seviye Yatay Çip Listesi
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(selectedExam.defaultGradeLevels, id: \.self) { grade in
                            Button(action: {
                                HapticService.shared.selection()
                                selectedGrade = grade
                            }) {
                                Text(grade)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(selectedGrade == grade ? .black : .white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 7)
                                    .background(
                                        Capsule().fill(selectedGrade == grade ? Color(red: 0.0, green: 0.96, blue: 0.61) : Color.white.opacity(0.06))
                                    )
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Ders ve Konu Seçimi
    private var subjectAndTopicSection: some View {
        GlassContainer(cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Ders ve Konu")
                    .font(.caption.weight(.bold))
                    .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))

                // Ders Seçici Menü
                Menu {
                    ForEach(selectedExam.defaultSubjects, id: \.self) { subject in
                        Button(action: { selectedSubject = subject }) {
                            Text(subject)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundColor(Color(red: 0.0, green: 0.82, blue: 1.0))
                        Text(selectedSubject)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                // Konu Yazma Alanı
                VStack(alignment: .leading, spacing: 6) {
                    Text("Çalışılacak Konu:")
                        .font(.caption)
                        .foregroundColor(.gray)

                    TextField("Örn: Türev, Problemler, Optik...", text: $topicText)
                        .padding(12)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .foregroundColor(.white)
                }

                // Hızlı Konu Önerileri Çipleri
                let suggestions = StudyTopic.suggestedTopics(for: selectedSubject)
                if !suggestions.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Popüler Konular:")
                            .font(.caption2)
                            .foregroundColor(.gray)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(suggestions, id: \.self) { sug in
                                    Button(action: {
                                        HapticService.shared.selection()
                                        topicText = sug
                                    }) {
                                        Text(sug)
                                            .font(.system(size: 11))
                                            .foregroundColor(topicText == sug ? Color(red: 0.0, green: 0.96, blue: 0.61) : .gray)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(
                                                Capsule().fill(Color.white.opacity(0.06))
                                            )
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Süre Ayarı (Slider & Preset)
    private var durationPickerSection: some View {
        GlassContainer(cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Hedef Çalışma Süresi")
                        .font(.caption.weight(.bold))
                        .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                    Spacer()
                    Text("\(Int(durationMinutes)) Dakika")
                        .font(.system(size: 18, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                }

                Slider(value: $durationMinutes, in: 15...180, step: 5)
                    .tint(Color(red: 0.0, green: 0.96, blue: 0.61))

                // Hızlı Süre Butonları
                HStack(spacing: 8) {
                    ForEach([25, 45, 60, 90, 120], id: \.self) { preset in
                        Button(action: {
                            HapticService.shared.selection()
                            durationMinutes = Double(preset)
                        }) {
                            Text("\(preset) dk")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Int(durationMinutes) == preset ? .black : .white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(Int(durationMinutes) == preset ? Color(red: 0.0, green: 0.96, blue: 0.61) : Color.white.opacity(0.06))
                                )
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Engellenecek Uygulama Bildirimi
    private var appBlockerNoticeCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "shield.lefthalf.filled.trianglebadge.exclamationmark")
                .font(.system(size: 22))
                .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))

            VStack(alignment: .leading, spacing: 2) {
                Text("Ekran Süresi Kalkanı")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Text("Instagram, TikTok, YouTube ve oyunlar kilitlenecek. Sadece 3 dakikalık acil izin hakkın olacak.")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.red.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
