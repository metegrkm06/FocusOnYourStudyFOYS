import SwiftUI

/// FOYS Ana Sekme Çubuğu (Tab Bar)
public struct MainTabView: View {
    @StateObject private var sessionVM = StudySessionViewModel.shared
    @StateObject private var settingsVM = SettingsViewModel.shared
    @State private var selectedTab: Int = 0

    public init() {}

    public var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                // Sekme 0: Ana Panel / Aktif Oturum
                Group {
                    if sessionVM.isSessionActive {
                        ActiveSessionView(sessionVM: sessionVM)
                    } else {
                        DashboardView(sessionVM: sessionVM, settingsVM: settingsVM)
                    }
                }
                .tabItem {
                    Label(sessionVM.isSessionActive ? "Ders" : "Odak", systemImage: sessionVM.isSessionActive ? "flame.fill" : "target")
                }
                .tag(0)

                // Sekme 1: Masa Saati / Screensaver Modu
                DeskClockScreenSaverView(sessionVM: sessionVM)
                    .tabItem {
                        Label("Masa Saati", systemImage: "clock.fill")
                    }
                    .tag(1)

                // Sekme 2: Ayarlar & Yapay Zeka
                SettingsView(settingsVM: settingsVM)
                    .tabItem {
                        Label("Ayarlar", systemImage: "gearshape.fill")
                    }
                    .tag(2)
            }
            .tint(Color(red: 0.0, green: 0.96, blue: 0.61))

            // Toast Bildirim Katmanı
            if let toast = sessionVM.toastMessage {
                Text(toast)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Color.black.opacity(0.85)))
                    .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                    .padding(.bottom, 64)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.35, dampingFraction: 0.8), value: sessionVM.toastMessage)
            }
        }
    }
}
