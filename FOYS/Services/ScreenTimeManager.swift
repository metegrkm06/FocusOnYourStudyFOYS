import Foundation
import SwiftUI
import Combine

#if canImport(FamilyControls)
import FamilyControls
#endif

#if canImport(ManagedSettings)
import ManagedSettings
#endif

/// Popüler dikkat dağıtıcı ve kullanıcının eklediği özel uygulama modeli
public struct DistractingAppItem: Identifiable, Hashable, Codable, Sendable {
    public var id: String
    public var name: String
    public var category: String
    public var iconSystemName: String
    public var colorHex: String
    public var isSelected: Bool
    public var isCustom: Bool

    public init(
        id: String = UUID().uuidString,
        name: String,
        category: String = "Sosyal Medya",
        iconSystemName: String = "app.fill",
        colorHex: String = "#00F59B",
        isSelected: Bool = true,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.iconSystemName = iconSystemName
        self.colorHex = colorHex
        self.isSelected = isSelected
        self.isCustom = isCustom
    }
}

/// Ekran Süresi Yetki Durumu
public enum ScreenTimeAuthStatus: Equatable, Sendable {
    case notDetermined
    case approved
    case restricted(String)
    case focusGuardActive
}

/// iOS Ekran Süresi ve Uygulama Bloklama Yöneticisi (FamilyControls & ManagedSettings & Focus Guard)
public final class ScreenTimeManager: ObservableObject, @unchecked Sendable {
    public static let shared = ScreenTimeManager()

    @Published public var isAuthorized: Bool = false
    @Published public var authStatus: ScreenTimeAuthStatus = .notDetermined
    @Published public var isShieldActive: Bool = false
    @Published public var isEmergencyPassActive: Bool = false
    @Published public var selectedAppItems: [DistractingAppItem] = []

    #if canImport(FamilyControls)
    @Published public var activitySelection = FamilyActivitySelection()
    #endif

    #if canImport(ManagedSettings)
    private let managedStore = ManagedSettingsStore()
    #endif

    private var emergencyTimer: AnyCancellable?

    private init() {
        loadPersistedApps()
        checkAuthorization()
    }

    // MARK: - Uygulama Listesi Yönetimi (Kullanıcı Kendi Uygulamalarını Ekleyebilir)
    public func loadPersistedApps() {
        if let savedData = UserDefaults.standard.data(forKey: "foys_selected_apps"),
           let decoded = try? JSONDecoder().decode([DistractingAppItem].self, from: savedData) {
            self.selectedAppItems = decoded
        } else {
            self.selectedAppItems = defaultAppList()
        }

        // Önceden Focus Guard modu açılmış mı?
        if UserDefaults.standard.bool(forKey: "foys_focus_guard_enabled") {
            self.isAuthorized = true
            self.authStatus = .focusGuardActive
        }
    }

    public func defaultAppList() -> [DistractingAppItem] {
        return [
            DistractingAppItem(id: "instagram", name: "Instagram", category: "Sosyal Medya", iconSystemName: "camera.circle.fill", colorHex: "#E1306C", isSelected: true),
            DistractingAppItem(id: "tiktok", name: "TikTok", category: "Kısa Video", iconSystemName: "play.circle.fill", colorHex: "#00F2FE", isSelected: true),
            DistractingAppItem(id: "youtube", name: "YouTube", category: "Video", iconSystemName: "play.rectangle.fill", colorHex: "#FF0000", isSelected: true),
            DistractingAppItem(id: "twitter", name: "X (Twitter)", category: "Sosyal Medya", iconSystemName: "bubble.left.and.bubble.right.fill", colorHex: "#1DA1F2", isSelected: true),
            DistractingAppItem(id: "snapchat", name: "Snapchat", category: "Sosyal Medya", iconSystemName: "message.circle.fill", colorHex: "#FFFC00", isSelected: true),
            DistractingAppItem(id: "reddit", name: "Reddit", category: "Sosyal Forum", iconSystemName: "text.bubble.fill", colorHex: "#FF4500", isSelected: true),
            DistractingAppItem(id: "netflix", name: "Netflix & Dizi", category: "Eğlence", iconSystemName: "tv.fill", colorHex: "#E50914", isSelected: false),
            DistractingAppItem(id: "brawl_stars", name: "Brawl Stars / Oyunlar", category: "Oyun", iconSystemName: "gamecontroller.fill", colorHex: "#FFA500", isSelected: true),
            DistractingAppItem(id: "discord", name: "Discord", category: "Mesajlaşma", iconSystemName: "bubble.left.fill", colorHex: "#5865F2", isSelected: false),
            DistractingAppItem(id: "pubg", name: "PUBG Mobile", category: "Oyun", iconSystemName: "target", colorHex: "#FFB703", isSelected: false)
        ]
    }

    public func saveAppSelection() {
        if let encoded = try? JSONEncoder().encode(selectedAppItems) {
            UserDefaults.standard.set(encoded, forKey: "foys_selected_apps")
        }
    }

    /// Kullanıcının kendi uygulamasını eklemesi
    public func addCustomApp(name: String, category: String = "Özel Uygulama", iconSystemName: String = "app.fill", colorHex: String = "#00F59B") {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let newItem = DistractingAppItem(
            id: UUID().uuidString,
            name: trimmedName,
            category: category,
            iconSystemName: iconSystemName,
            colorHex: colorHex,
            isSelected: true,
            isCustom: true
        )

        selectedAppItems.insert(newItem, at: 0)
        saveAppSelection()
    }

    /// Uygulama silme
    public func removeApp(id: String) {
        selectedAppItems.removeAll(where: { $0.id == id })
        saveAppSelection()
    }

    /// Tüm uygulamaları silme (Sıfırdan kendi listesini oluşturmak isteyenler için)
    public func removeAllApps() {
        selectedAppItems.removeAll()
        saveAppSelection()
    }

    /// Varsayılan popüler listeyi geri yükleme
    public func resetToDefaults() {
        selectedAppItems = defaultAppList()
        saveAppSelection()
    }

    public func toggleAppSelection(id: String) {
        if let idx = selectedAppItems.firstIndex(where: { $0.id == id }) {
            selectedAppItems[idx].isSelected.toggle()
            saveAppSelection()
        }
    }

    public func selectAllApps() {
        for idx in selectedAppItems.indices {
            selectedAppItems[idx].isSelected = true
        }
        saveAppSelection()
    }

    public func deselectAllApps() {
        for idx in selectedAppItems.indices {
            selectedAppItems[idx].isSelected = false
        }
        saveAppSelection()
    }

    public var activeBlockedAppNames: [String] {
        selectedAppItems.filter { $0.isSelected }.map { $0.name }
    }

    // MARK: - İzin Durumu Kontrolü
    public func checkAuthorization() {
        #if canImport(FamilyControls)
        if #available(iOS 16.0, *) {
            let status = AuthorizationCenter.shared.authorizationStatus
            DispatchQueue.main.async {
                if status == .approved {
                    self.isAuthorized = true
                    self.authStatus = .approved
                } else if UserDefaults.standard.bool(forKey: "foys_focus_guard_enabled") {
                    self.isAuthorized = true
                    self.authStatus = .focusGuardActive
                } else {
                    self.isAuthorized = false
                    self.authStatus = .notDetermined
                }
            }
            return
        }
        #endif

        if UserDefaults.standard.bool(forKey: "foys_focus_guard_enabled") {
            self.isAuthorized = true
            self.authStatus = .focusGuardActive
        } else {
            self.isAuthorized = false
            self.authStatus = .notDetermined
        }
    }

    // MARK: - İzin İsteme (Hata durumunda sessiz kalmaz, ayrıntılı raporlar)
    public func requestScreenTimeAuthorization() async -> ScreenTimeAuthStatus {
        #if canImport(FamilyControls)
        if #available(iOS 16.0, *) {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                let status = AuthorizationCenter.shared.authorizationStatus
                return await MainActor.run {
                    if status == .approved {
                        self.isAuthorized = true
                        self.authStatus = .approved
                        return .approved
                    } else {
                        let msg = "Apple izin onaylanmadı (durum: \(status))."
                        self.authStatus = .restricted(msg)
                        return .restricted(msg)
                    }
                }
            } catch {
                let errorMsg = error.localizedDescription
                print("FOYS FamilyControls Error: \(errorMsg)")
                return await MainActor.run {
                    // Sideloaded / Ücretsiz Apple ID ile imzalandığında FamilyControls kısıtlanır
                    self.authStatus = .restricted(errorMsg)
                    return .restricted(errorMsg)
                }
            }
        }
        #endif

        return await MainActor.run {
            self.authStatus = .focusGuardActive
            self.isAuthorized = true
            return .focusGuardActive
        }
    }

    /// Kullanıcı Sideloadly / AltStore ile yüklediğinde Apple FamilyControls yetkisi yoksa
    /// FOYS Akıllı Odak Koruması Modunu tek tıkla açar
    @MainActor
    public func activateFocusGuardMode() {
        self.isAuthorized = true
        self.authStatus = .focusGuardActive
        UserDefaults.standard.set(true, forKey: "foys_focus_guard_enabled")
        HapticService.shared.selection()
    }

    // MARK: - Uygulamaları Kilitle / Kalkanı Aç (Shield)
    @MainActor
    public func enableShield() {
        guard !isShieldActive else { return }
        isShieldActive = true
        isEmergencyPassActive = false

        #if canImport(ManagedSettings)
        if #available(iOS 16.0, *) {
            #if canImport(FamilyControls)
            if !activitySelection.applicationTokens.isEmpty || !activitySelection.categoryTokens.isEmpty {
                managedStore.shield.applications = activitySelection.applicationTokens
                managedStore.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(activitySelection.categoryTokens)
            } else {
                managedStore.shield.applicationCategories = .all()
            }
            #else
            managedStore.shield.applicationCategories = .all()
            #endif
        }
        #endif

        HapticService.shared.sessionStarted()
        print("FOYS: App Shield & Focus Guard Enabled for \(activeBlockedAppNames.count) apps")
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
        print("FOYS: App Shield & Focus Guard Disabled")
    }

    // MARK: - 3 Dakikalık Acil Durum İzni (Emergency Pass)
    @MainActor
    public func grantEmergencyPass(durationSeconds: Int = 180, onCompleted: @escaping () -> Void) {
        guard isShieldActive else { return }
        isEmergencyPassActive = true

        #if canImport(ManagedSettings)
        if #available(iOS 16.0, *) {
            managedStore.shield.applicationCategories = nil
            managedStore.shield.applications = nil
        }
        #endif

        HapticService.shared.emergencyWarning()
        NotificationService.shared.scheduleEmergencyWarningNotification(in: durationSeconds - 30)

        emergencyTimer?.cancel()
        emergencyTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in }

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(durationSeconds)) { [weak self] in
            guard let self = self, self.isEmergencyPassActive else { return }
            self.isEmergencyPassActive = false
            self.enableShield()
            onCompleted()
        }
    }
}
