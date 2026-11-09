import SwiftUI

@main
struct FOYSApp: App {
    @StateObject private var screenTime = ScreenTimeManager.shared
    @StateObject private var notifications = NotificationService.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
                .onAppear {
                    Task {
                        _ = await notifications.requestAuthorization()
                        _ = await screenTime.requestScreenTimeAuthorization()
                    }
                }
                .onOpenURL { url in
                    // Kestirmeler otomasyonu ile veya URL ile gelindiğinde
                    HapticService.shared.penaltyApplied()
                    if StudySessionViewModel.shared.isSessionActive {
                        StudySessionViewModel.shared.showToast("Ders süresindesin! 🎯 Uygulamalar kilitli.")
                    }
                }
        }
    }
}
