import SwiftUI

/// Engellenecek Uygulamaların Yönetim Sayfası
public struct AppBlockerSettingsView: View {
    @ObservedObject var screenTime = ScreenTimeManager.shared

    public init() {}

    public var body: some View {
        List {
            // 1. Ekran Süresi İzin Durumu
            Section(header: Text("iOS Ekran Süresi Entegrasyonu")) {
                HStack {
                    Image(systemName: screenTime.isAuthorized ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                        .foregroundColor(screenTime.isAuthorized ? .green : .orange)
                        .font(.system(size: 22))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(screenTime.isAuthorized ? "Ekran Süresi İzni Aktif" : "İzin Gerekli")
                            .font(.system(size: 15, weight: .bold))
                        Text(screenTime.isAuthorized ? "Uygulamalar sistem seviyesinde kilitlenebilir." : "Apple FamilyControls izni verin.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    if !screenTime.isAuthorized {
                        Button("İzin Ver") {
                            Task {
                                _ = await screenTime.requestScreenTimeAuthorization()
                            }
                        }
                        .font(.system(size: 13, weight: .bold))
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.vertical, 4)
            }

            // 2. Kilitlenecek Uygulamalar Listesi
            Section(
                header: Text("Kilitlenecek Dikkat Dağıtıcı Uygulamalar"),
                footer: Text("Ders çalışma süresi başladığında seçili olan tüm bu uygulamalar kilitlenir. Yalnızca 3 dakikalık acil izin veya çalışma kanıtı sonrasındaki testle açılabilir.")
            ) {
                ForEach(screenTime.selectedAppItems) { app in
                    Button(action: {
                        HapticService.shared.selection()
                        screenTime.toggleAppSelection(id: app.id)
                    }) {
                        HStack(spacing: 14) {
                            Image(systemName: app.iconSystemName)
                                .font(.system(size: 20))
                                .foregroundColor(app.isSelected ? Color(red: 0.0, green: 0.96, blue: 0.61) : .gray)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(app.name)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primary)
                                Text(app.category)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            Image(systemName: app.isSelected ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 20))
                                .foregroundColor(app.isSelected ? Color(red: 0.0, green: 0.96, blue: 0.61) : .gray.opacity(0.4))
                        }
                    }
                }
            }
        }
        .navigationTitle("Uygulama Engelleme")
        .navigationBarTitleDisplayMode(.inline)
    }
}
