import SwiftUI

/// Masa Saati & Always-On Ekran Koruyucu Görünümü
public struct DeskClockScreenSaverView: View {
    @ObservedObject var sessionVM: StudySessionViewModel
    @StateObject private var screenSaverVM = ScreenSaverViewModel()
    @ObservedObject var ambientSound = AmbientSoundService.shared
    @Environment(\.dismiss) private var dismiss

    public init(sessionVM: StudySessionViewModel) {
        self.sessionVM = sessionVM
    }

    public var body: some View {
        ZStack {
            // Tam OLED Siyah Arka Plan
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                // Üst Bar: Kapat & Dim Modu Butonları
                HStack {
                    Button(action: {
                        screenSaverVM.toggleDim()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: screenSaverVM.isDimmed ? "sun.max.fill" : "moon.fill")
                            Text(screenSaverVM.isDimmed ? "Aydınlat" : "Karart")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(.gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.white.opacity(0.1)))
                    }

                    Spacer()

                    // Ekran Koruyucudan Çıkış
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .opacity(screenSaverVM.isDimmed ? 0.3 : 1.0)

                Spacer()

                // Ana Dijital Saat Göstergesi
                VStack(spacing: 12) {
                    AestheticClockView(timeString: screenSaverVM.currentTimeString, fontSize: 62)
                        .shadow(color: Color(red: 0.0, green: 0.96, blue: 0.61).opacity(screenSaverVM.isDimmed ? 0.1 : 0.4), radius: 15, x: 0, y: 0)

                    Text(screenSaverVM.currentDateString)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.gray)
                }
                .opacity(screenSaverVM.isDimmed ? 0.4 : 1.0)

                // Aktif Ders ve Oturum Kalan Süresi
                if sessionVM.isSessionActive {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Text(sessionVM.currentSession.subject)
                                .font(.system(size: 16, weight: .heavy))
                                .foregroundColor(.white)
                            Text("•")
                                .foregroundColor(.gray)
                            Text(sessionVM.currentSession.topic)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }

                        HStack(spacing: 6) {
                            Image(systemName: "timer")
                                .font(.system(size: 13))
                            Text("Kalan: \(sessionVM.currentSession.formattedRemainingTime)")
                                .font(.system(size: 15, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color(red: 0.0, green: 0.96, blue: 0.61).opacity(0.12)))
                    }
                    .opacity(screenSaverVM.isDimmed ? 0.3 : 1.0)
                }

                Spacer()

                // Motivasyon Sözü
                Text("\"\(screenSaverVM.currentQuote)\"")
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundColor(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(screenSaverVM.isDimmed ? 0.2 : 0.8)

                // Alt Ortam Sesi Kontrol Kısayolu
                HStack(spacing: 12) {
                    ForEach(AmbientSoundType.allCases) { sound in
                        Button(action: {
                            HapticService.shared.selection()
                            ambientSound.setSound(sound)
                        }) {
                            Image(systemName: sound.iconName)
                                .font(.system(size: 14))
                                .foregroundColor(ambientSound.currentSound == sound && ambientSound.isPlaying ? Color(red: 0.0, green: 0.96, blue: 0.61) : .gray)
                                .padding(10)
                                .background(Circle().fill(Color.white.opacity(0.08)))
                        }
                    }
                }
                .padding(.bottom, 20)
                .opacity(screenSaverVM.isDimmed ? 0.3 : 1.0)
            }
        }
        .onTapGesture {
            // Ekrana dokununca karartmayı aç / kapat
            screenSaverVM.toggleDim()
        }
        .onAppear {
            screenSaverVM.activateScreenSaver()
        }
        .onDisappear {
            screenSaverVM.deactivateScreenSaver()
        }
    }
}
