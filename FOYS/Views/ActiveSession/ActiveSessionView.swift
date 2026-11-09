import SwiftUI

/// Aktif Ders Çalışma ve Odaklanma Ekranı
public struct ActiveSessionView: View {
    @ObservedObject var sessionVM: StudySessionViewModel
    @ObservedObject var ambientSound = AmbientSoundService.shared

    public init(sessionVM: StudySessionViewModel) {
        self.sessionVM = sessionVM
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.07, blue: 0.11).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 1. Üst Durum ve Ders Bilgisi
                        sessionHeaderCard

                        // 2. Dairesel İlerleme / Geri Sayım Halkası
                        progressRingSection

                        // 3. Ceza Uyarısı (Varsa)
                        if sessionVM.currentSession.penaltySeconds > 0 {
                            penaltyWarningBanner
                        }

                        // 4. Ortam Sesi Kontrol Çubuğu (Ambient Focus Sounds)
                        ambientSoundBar

                        // 5. Acil İzin & Masa Saati Butonları
                        quickActionButtonsRow

                        // 6. Dersi Bitir & Kilit Aç Butonu
                        GlowButton(
                            title: "Dersi Bitir & Kilit Aç",
                            icon: "checkmark.shield.fill",
                            gradientColors: [Color(red: 0.0, green: 0.96, blue: 0.61), Color(red: 0.0, green: 0.82, blue: 1.0)],
                            height: 56
                        ) {
                            sessionVM.promptProofUpload()
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                }

                // 3 Dakikalık Acil Durum Modalı
                if sessionVM.showEmergencyModal {
                    EmergencyPassModal(sessionVM: sessionVM)
                        .transition(.opacity)
                }
            }
            .navigationTitle("Aktif Odaklanma")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $sessionVM.showProofModal) {
                ProofUploadView(sessionVM: sessionVM)
            }
            .sheet(isPresented: $sessionVM.showQuizModal) {
                AIQuizView(sessionVM: sessionVM, quizVM: AIQuizViewModel_Shared)
            }
            .fullScreenCover(isPresented: $sessionVM.showScreenSaver) {
                DeskClockScreenSaverView(sessionVM: sessionVM)
            }
        }
    }

    // MARK: - Üst Ders Bilgisi Kartı
    private var sessionHeaderCard: some View {
        GlassContainer(cornerRadius: 18) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(red: 0.0, green: 0.96, blue: 0.61).opacity(0.15))
                        .frame(width: 48, height: 48)

                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(sessionVM.currentSession.subject)
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.white)

                    Text(sessionVM.currentSession.topic)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)

                    Text("\(sessionVM.currentSession.examType.shortTitle) • \(sessionVM.currentSession.gradeLevel)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(red: 0.0, green: 0.82, blue: 1.0))
                }

                Spacer()

                // Mod Rozeti
                VStack(alignment: .trailing, spacing: 4) {
                    Text(sessionVM.currentSession.mode == .timed ? "Süreli" : "Süresiz")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.white.opacity(0.1)))
                }
            }
            .padding(14)
        }
    }

    // MARK: - Dairesel İlerleme Halkası
    private var progressRingSection: some View {
        let isTimed = sessionVM.currentSession.mode == .timed
        let timeDisplay = isTimed ? sessionVM.currentSession.formattedRemainingTime : sessionVM.currentSession.formattedElapsedTime
        let statusDisplay = isTimed ? "Kalan Süre" : "Geçen Süre (Süresiz)"
        let ringColor = sessionVM.currentSession.penaltySeconds > 0 ? Color.orange : Color(red: 0.0, green: 0.96, blue: 0.61)

        return CircularProgressRing(
            progress: sessionVM.currentSession.progress,
            timeText: timeDisplay,
            statusText: statusDisplay,
            ringColor: ringColor,
            lineWidth: 18,
            size: 250
        )
        .padding(.vertical, 10)
    }

    // MARK: - Ceza Uyarısı
    private var penaltyWarningBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: 2) {
                Text("Ek Kilit Cezası Aktif")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Text("Testteki yanlışlardan dolayı +\(sessionVM.currentSession.penaltyMinutesAdded) dakika ek süre uygulandı.")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(14)
        .background(Color.orange.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.orange.opacity(0.3), lineWidth: 1))
    }

    // MARK: - Ortam Sesi Kontrol Çubuğu (Pink Noise, Alpha Wave, Rain)
    private var ambientSoundBar: some View {
        GlassContainer(cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: ambientSound.isPlaying ? "waveform" : "speaker.wave.2.fill")
                        .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                    Text("Odaklanma Ambiyansı")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    if ambientSound.isPlaying {
                        Text("Çalıyor")
                            .font(.system(size: 10, weight: .heavy))
                            .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(AmbientSoundType.allCases) { sound in
                            Button(action: {
                                HapticService.shared.selection()
                                ambientSound.setSound(sound)
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: sound.iconName)
                                        .font(.system(size: 11))
                                    Text(sound.rawValue)
                                        .font(.system(size: 11, weight: .medium))
                                }
                                .foregroundColor(ambientSound.currentSound == sound && ambientSound.isPlaying ? .black : .white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(
                                    Capsule().fill(ambientSound.currentSound == sound && ambientSound.isPlaying ? Color(red: 0.0, green: 0.96, blue: 0.61) : Color.white.opacity(0.06))
                                )
                            }
                        }
                    }
                }
            }
            .padding(14)
        }
    }

    // MARK: - Acil İzin & Masa Saati Butonları
    private var quickActionButtonsRow: some View {
        HStack(spacing: 12) {
            // 3 Dakikalık Acil İzin
            Button(action: {
                sessionVM.useEmergencyPass()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "hourglass")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.orange)
                    Text("3 Dk Acil İzin")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.orange.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color.orange.opacity(0.3), lineWidth: 1))
            }

            // Masa Saati Screensaver
            Button(action: {
                sessionVM.showScreenSaver = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "clock.badge.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 0.0, green: 0.82, blue: 1.0))
                    Text("Masa Saati")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color(red: 0.0, green: 0.82, blue: 1.0).opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color(red: 0.0, green: 0.82, blue: 1.0).opacity(0.3), lineWidth: 1))
            }
        }
    }
}
