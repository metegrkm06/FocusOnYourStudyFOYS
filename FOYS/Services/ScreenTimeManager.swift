import Foundation
import SwiftUI
import Combine

#if canImport(FamilyControls)
import FamilyControls
#endif

#if canImport(ManagedSettings)
import ManagedSettings
#endif

/// Popüler dikkat dağıtıcı uygulama bilgisi
public struct DistractingAppItem: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let name: String
    public let category: String
    public let iconSystemName: String
    public var isSelected: Bool

    public init(id: String, name: String, category: String, iconSystemName: String, isSelected: Bool = true) {
        self.id = id
        self.name = name
        self.category = category
        self.iconSystemName = iconSystemName
        self.isSelected = isSelected
    }
}

/// iOS Ekran Süresi ve Uygulama Bloklama Yöneticisi (FamilyControls & ManagedSettings)
public final class ScreenTimeManager: ObservableObject, @unchecked Sendable {
    public static let shared = ScreenTimeManager()

    @Published public var isAuthorized: Bool = false
    @Published public var isShieldActive: Bool = false
    @Published public var isEmergencyPassActive: Bool = false
    @Published public var selectedAppItems: [DistractingAppItem] = []

    #if canImport(ManagedSettings)
    private let managedStore = ManagedSettingsStore()
    #endif

    private var emergencyTimer: AnyCancellable?

    private init() {
        loadDefaultDistractingApps()
        checkAuthorization()
    }

    /// Varsayılan popüler dikkat dağıtıcı uygulamalar
    private func loadDefaultDistractingApps() {
        let defaults: [DistractingAppItem] = [
            DistractingAppItem(id: "com.burbn.instagram", name: "Instagram", category: "Sosyal Medya", iconSystemName: "camera.circle.fill", isSelected: true),
            DistractingAppItem(id: "com.zhiliaoapp.musically", name: "TikTok", category: "Kısa Video", iconSystemName: "play.circle.fill", isSelected: true),
            DistractingAppItem(id: "com.google.ios.youtube", name: "YouTube & Shorts", category: "Video", iconSystemName: "play.rectangle.fill", isSelected: true),
            DistractingAppItem(id: "com.atebits.Tweetie2", name: "X (Twitter)", category: "Sosyal Medya", iconSystemName: "bubble.left.and.bubble.right.fill", isSelected: true),
            DistractingAppItem(id: "com.toyopagroup.picaboo", name: "Snapchat", category: "Sosyal Medya", iconSystemName: "message.circle.fill", isSelected: true),
            DistractingAppItem(id: "com.reddit.Reddit", name: "Reddit", category: "Sosyal Forum", iconSystemName: "text.bubble.fill", isSelected: true),
            DistractingAppItem(id: "com.netflix.Netflix", name: "Netflix & Dizi", category: "Eğlence", iconSystemName: "tv.fill", isSelected: false),
            DistractingAppItem(id: "com.riotgames.league.wildrift", name: "Oyunlar (Mobil)", category: "Oyun", iconSystemName: "gamecontroller.fill", isSelected: false)
        ]

        if let savedData = UserDefaults.standard.data(forKey: "foys_selected_apps"),
           let decoded = try? JSONDecoder().decode([DistractingAppItem].self, from: savedData) {
            self.selectedAppItems = decoded
        } else {
            self.selectedAppItems = defaults
        }
    }

    public func saveAppSelection() {
        if let encoded = try? JSONEncoder().encode(selectedAppItems) {
            UserDefaults.standard.set(encoded, forKey: "foys_selected_apps")
        }
    }

    public func toggleAppSelection(id: String) {
        if let idx = selectedAppItems.firstIndex(where: { $0.id == id }) {
            selectedAppItems[idx].isSelected.toggle()
            saveAppSelection()
        }
    }

    public var activeBlockedAppNames: [String] {
        selectedAppItems.filter { $0.isSelected }.map { $0.name }
    }

    // MARK: - İzin İsteme (FamilyControls)
    public func checkAuthorization() {
        #if canImport(FamilyControls)
        if #available(iOS 16.0, *) {
            let status = AuthorizationCenter.shared.authorizationStatus
            DispatchQueue.main.async {
                self.isAuthorized = (status == .approved)
            }
        } else {
            self.isAuthorized = true
        }
        #else
        self.isAuthorized = true
        #endif
    }

    public func requestScreenTimeAuthorization() async -> Bool {
        #if canImport(FamilyControls)
        if #available(iOS 16.0, *) {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                let status = AuthorizationCenter.shared.authorizationStatus
                await MainActor.run {
                    self.isAuthorized = (status == .approved)
                }
                return status == .approved
            } catch {
                print("FamilyControls requestAuthorization error: \(error)")
                await MainActor.run {
                    self.isAuthorized = false
                }
                return false
            }
        }
        #endif
        await MainActor.run {
            self.isAuthorized = true
        }
        return true
    }

    // MARK: - Uygulamaları Kilitle / Kalkanı Aç (Shield)
    @MainActor
    public func enableShield() {
        guard !isShieldActive else { return }
        isShieldActive = true
        isEmergencyPassActive = false

        #if canImport(ManagedSettings)
        if #available(iOS 16.0, *) {
            // ManagedSettingsStore shield etkinleştirilir
            // Tüm dikkat dağıtıcı kategoriler kilitlenir
            managedStore.shield.applicationCategories = .all()
        }
        #endif

        HapticService.shared.sessionStarted()
        print("FOYS: App Shield Enabled (Uygulamalar kilitlendi)")
    }

    // MARK: - Kalkanı Kaldır (Tüm Uygulamaların Kilidini Aç)
    @MainActor
    public func disableShield() {
        isShieldActive = false
        isEmergencyPassActive = false
        emergencyTimer?.cancel()
        emergencyTimer = nil

        #if canImport(ManagedSettings)
        if #available(iOS 16.0, *) {
            managedStore.shield.applications = nil
            managedStore.shield.applicationCategories = nil
        }
        #endif

        HapticService.shared.quizSuccess()
        print("FOYS: App Shield Disabled (Kilitler kaldırıldı)")
    }

    // MARK: - 3 Dakikalık Acil Durum İzni (Emergency Pass)
    @MainActor
    public func grantEmergencyPass(durationSeconds: Int = 180, onCompleted: @escaping () -> Void) {
        guard isShieldActive else { return }
        isEmergencyPassActive = true

        #if canImport(ManagedSettings)
        if #available(iOS 16.0, *) {
            // Geçici olarak kalkanı kaldır
            managedStore.shield.applicationCategories = nil
            managedStore.shield.applications = nil
        }
        #endif

        HapticService.shared.emergencyWarning()
        NotificationService.shared.scheduleEmergencyWarningNotification(in: durationSeconds - 30)

        emergencyTimer?.cancel()
        emergencyTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                // Geri sayım tamamlandığında tekrar kilitlenir
            }

        // 3 dakika sonra otomatik tekrar kilit açma
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(durationSeconds)) { [weak self] in
            guard let self = self, self.isEmergencyPassActive else { return }
            self.isEmergencyPassActive = false
            self.enableShield()
            onCompleted()
        }
    }
}
