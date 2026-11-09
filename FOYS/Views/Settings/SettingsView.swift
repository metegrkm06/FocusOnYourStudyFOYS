import SwiftUI

/// Genel Ayarlar Ekranı
public struct SettingsView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @State private var showResetAlert: Bool = false

    public init(settingsVM: SettingsViewModel) {
        self.settingsVM = settingsVM
    }

    public var body: some View {
        NavigationStack {
            List {
                // 1. AI Sağlayıcı ve API Anahtarları
                Section(header: Text("Yapay Zeka Yapılandırması")) {
                    NavigationLink {
                        APIKeySettingsView(settingsVM: settingsVM)
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(red: 0.0, green: 0.96, blue: 0.61).opacity(0.18))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "cpu")
                                    .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("AI Sağlayıcı & API Key")
                                    .font(.system(size: 15, weight: .semibold))
                                Text(settingsVM.config.selectedProvider.rawValue)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }

                // 2. Ekran Süresi & Engellenen Uygulamalar
                Section(header: Text("Ekran Süresi ve Kalkan")) {
                    NavigationLink {
                        AppBlockerSettingsView()
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color.orange.opacity(0.18))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "shield.fill")
                                    .foregroundColor(.orange)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Engellenecek Uygulamalar")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Instagram, TikTok, YouTube vb.")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }

                // 3. İstatistikler & Sıfırlama
                Section(header: Text("Çalışma Geçmişi")) {
                    HStack {
                        Text("Toplam Odaklanma")
                        Spacer()
                        Text(settingsVM.stats.formattedTotalHours)
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Text("Tamamlanan Oturumlar")
                        Spacer()
                        Text("\(settingsVM.stats.totalSessionsCompleted)")
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Text("Kullanılan Acil İzinler")
                        Spacer()
                        Text("\(settingsVM.stats.totalEmergencyPassesUsed)")
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Text("Sınav Başarı Oranı")
                        Spacer()
                        Text(String(format: "%%%0.f", settingsVM.stats.quizSuccessRate))
                            .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                    }

                    Button(role: .destructive, action: {
                        showResetAlert = true
                    }) {
                        Text("İstatistikleri Sıfırla")
                    }
                }

                // 4. Hakkında
                Section(header: Text("Hakkında")) {
                    HStack {
                        Text("Uygulama")
                        Spacer()
                        Text("FOYS (Focus On Your Study)")
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Text("Sürüm")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Text("Geliştirici")
                        Spacer()
                        Text("metegrkm06")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Ayarlar")
            .alert("İstatistikleri Sıfırla", isPresented: $showResetAlert) {
                Button("Sıfırla", role: .destructive) {
                    settingsVM.resetStats()
                }
                Button("İptal", role: .cancel) {}
            } message: {
                Text("Tüm ders çalışma geçmişiniz ve süre kayıtlarınız silinecektir. Devam etmek istiyor musunuz?")
            }
        }
    }
}
