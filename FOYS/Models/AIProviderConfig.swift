import Foundation

/// Desteklenen Yapay Zeka Sağlayıcıları
public enum AIProviderType: String, CaseIterable, Identifiable, Codable, Sendable {
    case gemini = "Google Gemini (Ücretsiz API)"
    case openRouter = "OpenRouter (Ücretsiz & Çoklu Model)"
    case nvidia = "NVIDIA NIM (Ücretsiz Geliştirici)"
    case groq = "Groq Cloud (Işık Hızında)"
    case customMCP = "Özel API / MCP Sunucusu"
    case offlineSimulator = "Dahili Çevrimdışı Soru Bankası"

    public var id: String { rawValue }

    public var defaultModelName: String {
        switch self {
        case .gemini:
            return "gemini-1.5-flash"
        case .openRouter:
            return "google/gemini-2.0-flash-exp:free"
        case .nvidia:
            return "meta/llama-3.2-11b-vision-instruct"
        case .groq:
            return "llama-3.2-11b-vision-preview"
        case .customMCP:
            return "gpt-4o-mini"
        case .offlineSimulator:
            return "offline-curriculum-v1"
        }
    }

    public var defaultBaseURL: String {
        switch self {
        case .gemini:
            return "https://generativelanguage.googleapis.com"
        case .openRouter:
            return "https://openrouter.ai/api/v1"
        case .nvidia:
            return "https://integrate.api.nvidia.com/v1"
        case .groq:
            return "https://api.groq.com/openai/v1"
        case .customMCP:
            return "http://localhost:8000/v1"
        case .offlineSimulator:
            return ""
        }
    }

    public var setupGuideURL: String {
        switch self {
        case .gemini:
            return "https://aistudio.google.com/app/apikey"
        case .openRouter:
            return "https://openrouter.ai/keys"
        case .nvidia:
            return "https://build.nvidia.com"
        case .groq:
            return "https://console.groq.com/keys"
        case .customMCP:
            return "https://modelcontextprotocol.io"
        case .offlineSimulator:
            return ""
        }
    }

    public var badgeColorHex: String {
        switch self {
        case .gemini: return "#4285F4"
        case .openRouter: return "#6366F1"
        case .nvidia: return "#76B900"
        case .groq: return "#F55036"
        case .customMCP: return "#10B981"
        case .offlineSimulator: return "#8B5CF6"
        }
    }
}

/// AI Sağlayıcı Konfigürasyon Modeli
public struct AIProviderConfig: Codable, Sendable {
    public var selectedProvider: AIProviderType
    public var geminiApiKey: String
    public var openRouterApiKey: String
    public var nvidiaApiKey: String
    public var groqApiKey: String
    public var customBaseURL: String
    public var customApiKey: String
    public var customModelName: String

    public init(
        selectedProvider: AIProviderType = .gemini,
        geminiApiKey: String = "",
        openRouterApiKey: String = "",
        nvidiaApiKey: String = "",
        groqApiKey: String = "",
        customBaseURL: String = "https://api.openai.com/v1",
        customApiKey: String = "",
        customModelName: String = "gpt-4o-mini"
    ) {
        self.selectedProvider = selectedProvider
        self.geminiApiKey = geminiApiKey
        self.openRouterApiKey = openRouterApiKey
        self.nvidiaApiKey = nvidiaApiKey
        self.groqApiKey = groqApiKey
        self.customBaseURL = customBaseURL
        self.customApiKey = customApiKey
        self.customModelName = customModelName
    }

    /// Aktif sağlayıcının API anahtarı
    public var currentApiKey: String {
        switch selectedProvider {
        case .gemini: return geminiApiKey
        case .openRouter: return openRouterApiKey
        case .nvidia: return nvidiaApiKey
        case .groq: return groqApiKey
        case .customMCP: return customApiKey
        case .offlineSimulator: return ""
        }
    }

    /// Aktif sağlayıcının API anahtarı girilmiş mi?
    public var hasValidKeyForCurrentProvider: Bool {
        if selectedProvider == .offlineSimulator {
            return true
        }
        return !currentApiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
