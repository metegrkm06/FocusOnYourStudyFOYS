import SwiftUI

/// FOYS Ana Gösterge Paneli (Dashboard)
public struct DashboardView: View {
    @ObservedObject var sessionVM: StudySessionViewModel
    @ObservedObject var settingsVM: SettingsViewModel
    @ObservedObject var screenTime = ScreenTimeManager.shared

    public init(sessionVM: StudySessionViewModel, settingsVM: SettingsViewModel) {
        self.sessionVM = sessionVM
        self.settingsVM = settingsVM
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.07, blue: 0.11).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // 1. Üst Başlık & Streak Rozeti
                        headerTopBar

                        // 2. Aktif Oturum Varsa Hero Banner
                        if sessionVM.isSessionActive {
                            activeSessionHeroBanner
                        } else {
                            startSessionHeroCard
                        }

                        // 3. Günlük Çalışma İstatistik Özeti
                        statsSummaryGrid

                        // 4. Hızlı Odaklanma Başlatıcıları
                        quickPresetsSection

                        // 5. Engellenen Uygulamalar Özeti
                        blockedAppsOverviewCard

                        // 6. Masa Saati / Screensaver Kısayolu
                        screensaverPromoCard
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 10)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("FOYS")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $sessionVM.showStartSheet) {
                StartSessionSheet(sessionVM: sessionVM)
            }
        }
    }

    // MARK: - Üst Başlık & Streak
    private var headerTopBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Focus On Your Study")
                    .font(.system(size: 20, weight: .black))
                    .foregroundColor(.white)
                Text("Telefonu bırak, hedefine odaklan.")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            // Streak Rozeti
            HStack(spacing: 5) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                Text("\(settingsVM.stats.currentDayStreak) Gün")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.orange.opacity(0.18))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.orange.opacity(0.4), lineWidth: 1))
        }
    }

    // MARK: - Aktif Oturum Varsa Gösterilen Banner
    private var activeSessionHeroBanner: some View {
        GlassContainer(
            cornerRadius: 22,
            strokeColor: Color(red: 0.0, green: 0.96, blue: 0.61).opacity(0.5),
            backgroundColor: Color(red: 0.07, green: 0.16, blue: 0.14)
        ) {
            VStack(spacing: 16) {
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(red: 0.0, green: 0.96, blue: 0.61))
                            .frame(width: 10, height: 10)
                        Text("DERS ÇALIŞMA AKTİF")
                            .font(.system(size: 11, weight: .heavy))
                            .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                    }

                    Spacer()

                    Text(sessionVM.currentSession.mode.rawValue)
                        .font(.caption2.weight(.bold))
                        .foregroundColor(.gray)
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(sessionVM.currentSession.subject)
                            .font(.system(size: 22, weight: .heavy))
                            .foregroundColor(.white)
                        Text(sessionVM.currentSession.topic)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    Spacer()

                    Text(sessionVM.currentSession.formattedRemainingTime)
                        .font(.system(size: 28, weight: .black, design: .monospaced))
                        .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                }

                // Oturumu Aç Butonu
                Button(action: {
                    // Ana sekmede aktif oturuma geçilir
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.right.circle.fill")
                        Text("Oturum Ekranına Git")
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color(red: 0.0, green: 0.96, blue: 0.61))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(18)
        }
    }

    // MARK: - Başlatma Hero Kartı (Oturum Yokken)
    private var startSessionHeroCard: some View {
        GlassContainer(cornerRadius: 22) {
            VStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.0, green: 0.96, blue: 0.61).opacity(0.15))
                        .frame(width: 80, height: 80)

                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 38))
                        .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                }
                .padding(.top, 4)

                VStack(spacing: 6) {
                    Text("Dikkat Dağıtıcıları Engelle")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(.white)

                    Text("Instagram, TikTok ve oyunları kapat. Ders bitince fotoğrafını at, yapay zekanın 3 sorusunu bilip kilidi aç.")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

                GlowButton(
                    title: "Ders Çalışmaya Başla",
                    icon: "play.fill",
                    height: 52
                ) {
                    sessionVM.showStartSheet = true
                }
            }
            .padding(20)
        }
    }

    // MARK: - İstatistikler Özeti Grid
    private var statsSummaryGrid: some View {
        HStack(spacing: 12) {
            statBox(
                title: "Toplam Odak",
                value: settingsVM.stats.formattedTotalHours,
                icon: "clock.fill",
                color: Color(red: 0.0, green: 0.96, blue: 0.61)
            )

            statBox(
                title: "Tamamlanan",
                value: "\(settingsVM.stats.totalSessionsCompleted) Ders",
                icon: "checkmark.seal.fill",
                color: Color(red: 0.0, green: 0.82, blue: 1.0)
            )

            statBox(
                title: "Test Başarısı",
                value: String(format: "%%%0.f", settingsVM.stats.quizSuccessRate),
                icon: "brain.head.profile",
                color: Color(red: 0.7, green: 0.5, blue: 1.0)
            )
        }
    }

    private func statBox(title: String, value: String, icon: String, color: Color) -> some View {
        GlassContainer(cornerRadius: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)

                Text(value)
                    .font(.system(size: 17, weight: .heavy, design: .monospaced))
                    .foregroundColor(.white)

                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Hızlı Presets
    private var quickPresetsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hızlı Başlatıcılar")
                .font(.caption.weight(.bold))
                .foregroundColor(.gray)

            HStack(spacing: 10) {
                quickPresetChip(title: "25 Dk Pomodoro", minutes: 25, icon: "timer")
                quickPresetChip(title: "45 Dk Derin Çalışma", minutes: 45, icon: "flame.fill")
                quickPresetChip(title: "Süresiz Blok", minutes: 0, isIndefinite: true, icon: "infinity")
            }
        }
    }

    private func quickPresetChip(title: String, minutes: Int, isIndefinite: Bool = false, icon: String) -> some View {
        Button(action: {
            HapticService.shared.selection()
            sessionVM.startSession(
                mode: isIndefinite ? .indefinite : .timed,
                durationMinutes: minutes,
                examType: .yksTyt,
                gradeLevel: "12. Sınıf",
                subject: "Temel Matematik",
                topic: "Problemler"
            )
        }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    // MARK: - Engellenecek Uygulamalar Kartı
    private var blockedAppsOverviewCard: some View {
        GlassContainer(cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "app.badge.checkmark.fill")
                        .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                    Text("Kilitlenecek Uygulamalar")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("\(screenTime.activeBlockedAppNames.count) Seçili")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(screenTime.selectedAppItems.filter { $0.isSelected }) { app in
                            HStack(spacing: 4) {
                                Image(systemName: app.iconSystemName)
                                    .font(.system(size: 10))
                                Text(app.name)
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Capsule().fill(Color.white.opacity(0.08)))
                        }
                    }
                }
            }
            .padding(16)
        }
    }

    // MARK: - Masa Saati Promosu
    private var screensaverPromoCard: some View {
        Button(action: {
            sessionVM.showScreenSaver = true
        }) {
            HStack(spacing: 14) {
                Image(systemName: "clock.badge.fill")
                    .font(.system(size: 28))
                    .foregroundColor(Color(red: 0.0, green: 0.82, blue: 1.0))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Masa Saati & Always-On Modu")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    Text("Telefonu masaya koy, ekran hiç kapanmasın ve odak sesleriyle çalış.")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}
