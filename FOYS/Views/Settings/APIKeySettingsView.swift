import SwiftUI

/// Çoklu AI Sağlayıcı ve API Anahtarı Yönetim Sayfası
public struct APIKeySettingsView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @State private var isKeyVisible: Bool = false

    public init(settingsVM: SettingsViewModel) {
        self.settingsVM = settingsVM
    }

    public var body: some View {
        Form {
            // 1. Sağlayıcı Seçimi
            Section(header: Text("Aktif Yapay Zeka Sağlayıcısı")) {
                Picker("Model / Sağlayıcı", selection: $settingsVM.config.selectedProvider) {
                    ForEach(AIProviderType.allCases) { provider in
                        Text(provider.rawValue).tag(provider)
                    }
                }
                .onChange(of: settingsVM.config.selectedProvider) { _ in
                    settingsVM.saveConfig()
                    settingsVM.testConnectionStatus = nil
                }
            }

            // 2. Seçili Sağlayıcıya Özel Anahtar Girişi
            Section(header: Text("API Anahtarı Yapılandırması"), footer: Text(providerFooterNote)) {
                switch settingsVM.config.selectedProvider {
                case .gemini:
                    apiKeyField(title: "Gemini API Key", text: $settingsVM.config.geminiApiKey)
                    guideLink(url: AIProviderType.gemini.setupGuideURL, title: "Google AI Studio'dan Ücretsiz Key Al")

                case .openRouter:
                    apiKeyField(title: "OpenRouter API Key", text: $settingsVM.config.openRouterApiKey)
                    guideLink(url: AIProviderType.openRouter.setupGuideURL, title: "OpenRouter'dan Ücretsiz / Uygun Key Al")

                case .nvidia:
                    apiKeyField(title: "NVIDIA NIM Key", text: $settingsVM.config.nvidiaApiKey)
                    guideLink(url: AIProviderType.nvidia.setupGuideURL, title: "build.nvidia.com'dan Ücretsiz Key Al")

                case .groq:
                    apiKeyField(title: "Groq Cloud Key", text: $settingsVM.config.groqApiKey)
                    guideLink(url: AIProviderType.groq.setupGuideURL, title: "console.groq.com'dan Ücretsiz Key Al")

                case .customMCP:
                    TextField("Base URL", text: $settingsVM.config.customBaseURL)
                    TextField("Model Adı", text: $settingsVM.config.customModelName)
                    apiKeyField(title: "Bearer Token / Key", text: $settingsVM.config.customApiKey)

                case .offlineSimulator:
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                        Text("Dahili Müfredat Modu Aktif. Harici internet ve API Key gerektirmez.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            // 3. Bağlantı Testi
            Section {
                Button(action: {
                    settingsVM.saveConfig()
                    Task {
                        await settingsVM.testCurrentAPIKey()
                    }
                }) {
                    HStack {
                        if settingsVM.isTestingConnection {
                            ProgressView()
                                .padding(.trailing, 6)
                        } else {
                            Image(systemName: "network")
                        }
                        Text("API Bağlantısını Test Et")
                            .font(.body.weight(.bold))
                    }
                }
                .disabled(settingsVM.isTestingConnection)

                if let status = settingsVM.testConnectionStatus {
                    Text(status)
                        .font(.caption)
                        .foregroundColor(status.contains("✅") ? .green : .orange)
                }
            }
        }
        .navigationTitle("AI Sağlayıcı Ayarları")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func apiKeyField(title: String, text: Binding<String>) -> some View {
        HStack {
            if isKeyVisible {
                TextField(title, text: text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            } else {
                SecureField(title, text: text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }

            Button(action: { isKeyVisible.toggle() }) {
                Image(systemName: isKeyVisible ? "eye.slash" : "eye")
                    .foregroundColor(.gray)
            }
        }
        .onChange(of: text.wrappedValue) { _ in
            settingsVM.saveConfig()
        }
    }

    private func guideLink(url: String, title: String) -> some View {
        Link(destination: URL(string: url) ?? URL(string: "https://google.com")!) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.blue)
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }

    private var providerFooterNote: String {
        switch settingsVM.config.selectedProvider {
        case .gemini:
            return "Google Gemini Flash, 1.5 sürümüyle fotoğraf analizi ve soru üretimi için en yüksek başarıyı sağlar. Ücretsiz kota mevcuttur."
        case .openRouter:
            return "OpenRouter; Llama 3, Qwen ve Gemini Flash modellerini tek çatı altında ücretsiz ve hızlıca çalıştırmanıza olanak tanır."
        case .nvidia:
            return "NVIDIA NIM, geliştiricilere 1000'lerce ücretsiz API kredisi vererek Llama Vision modellerini çalıştırır."
        case .groq:
            return "Groq, LPUs işlemcileri sayesinde anında milisaniyeler içinde kilit açma soruları üretir."
        case .customMCP:
            return "Kendi yerel MCP sunucunuzu, Ollama'yı veya OpenAI uyumlu herhangi bir özel proxy ucunu bağlayabilirsiniz."
        case .offlineSimulator:
            return "İnternet bağlantınız olmasa bile FOYS'un dahili soru bankasıyla derslerinizi güvenle kilitleyip çözebilirsiniz."
        }
    }
}
