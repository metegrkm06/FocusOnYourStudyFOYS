import Foundation
import UserNotifications

/// Yerel Bildirim Yöneticisi
public final class NotificationService: NSObject, ObservableObject, @unchecked Sendable {
    public static let shared = NotificationService()

    @Published public var isAuthorized: Bool = false

    override private init() {
        super.init()
        checkAuthorization()
    }

    public func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                self.isAuthorized = granted
            }
            return granted
        } catch {
            return false
        }
    }

    /// Ders süresi bittiğinde bildirim gönder
    public func scheduleSessionCompletedNotification(in seconds: Int, subject: String, topic: String) {
        cancelAllNotifications()
        guard seconds > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Ders Süresi Tamamlandı! 🎯"
        content.body = "\(subject) - \(topic) çalışman bitti. Uygulamaların kilidini açmak için çalışma kanıtını yükle ve testi çöz!"
        content.sound = .defaultRingtone

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: "foys_session_done", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    /// Acil durum izninin bitmesine 30 saniye kala uyarı bildirimi
    public func scheduleEmergencyWarningNotification(in seconds: Int = 150) {
        let content = UNMutableNotificationContent()
        content.title = "Acil İzin Bitiyor! ⏳"
        content.body = "3 dakikalık acil durum izninin bitmesine 30 saniye kaldı. Uygulamalar tekrar kilitlenecek."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
        let request = UNNotificationRequest(identifier: "foys_emergency_warning", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    public func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
