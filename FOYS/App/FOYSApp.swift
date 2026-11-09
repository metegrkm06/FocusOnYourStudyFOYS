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
        }
    }
}
