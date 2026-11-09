import SwiftUI
import Combine

/// Ayarlar, API Anahtarları ve İstatistikler ViewModel'i
@MainActor
public final class SettingsViewModel: ObservableObject {
    public static let shared = SettingsViewModel()

    @Published public var config: AIProviderConfig
    @Published public var stats: StudyStats
    @Published public var isDarkMode: Bool = true
    @Published public var testConnectionStatus: String? = nil
    @Published public var isTestingConnection: Bool = false

    private let configKey = "foys_ai_provider_config"
    private let statsKey = "foys_study_stats"

    public init() {
        if let data = UserDefaults.standard.data(forKey: configKey),
           let decoded = try? JSONDecoder().decode(AIProviderConfig.self, from: data) {
            self.config = decoded
        } else {
            self.config = AIProviderConfig()
        }

        if let data = UserDefaults.standard.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode(StudyStats.self, from: data) {
            self.stats = decoded
        } else {
            self.stats = StudyStats()
        }
    }

    public func saveConfig() {
        if let encoded = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(encoded, forKey: configKey)
        }
    }

    public func saveStats() {
        if let encoded = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encoded, forKey: statsKey)
        }
    }

    public func resetStats() {
        self.stats = StudyStats()
        saveStats()
    }

    public func testCurrentAPIKey() async {
        isTestingConnection = true
        testConnectionStatus = nil

        let testKey = config.currentApiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        if config.selectedProvider == .offlineSimulator {
            testConnectionStatus = "✅ Dahili Müfredat Soru Bankası Aktif (API Anahtarı Gerekmez)"
            isTestingConnection = false
            return
        }

        guard !testKey.isEmpty else {
            testConnectionStatus = "⚠️ Lütfen \(config.selectedProvider.rawValue) için geçerli bir API anahtarı girin."
            isTestingConnection = false
            return
        }

        let dummyImage = UIImage(systemName: "book.fill") ?? UIImage()
        let result = await AIService.shared.verifyStudyProof(
            image: dummyImage,
            examType: .yksTyt,
            subject: "Matematik",
            topic: "Test",
            config: config
        )

        if result.isLegit {
            testConnectionStatus = "✅ Bağlantı Başarılı! Yapay zeka modeli aktif ve yanıt veriyor."
        } else {
            testConnectionStatus = "ℹ️ Bağlantı kuruldu: \(result.notesSummary)"
        }
        isTestingConnection = false
    }
}
