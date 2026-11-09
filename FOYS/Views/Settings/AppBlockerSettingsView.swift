import SwiftUI

#if canImport(FamilyControls)
import FamilyControls
#endif

/// Engellenecek Uygulamaların Yönetim Sayfası & Kendi Uygulamalarını Ekleme
public struct AppBlockerSettingsView: View {
    @ObservedObject var screenTime = ScreenTimeManager.shared
    @State private var showAddCustomAppSheet: Bool = false
    @State private var showShortcutsGuideSheet: Bool = false
    @State private var showApplePicker: Bool = false
    @State private var isRequestingAuth: Bool = false
    @State private var searchQuery: String = ""
    @State private var authErrorMessage: String? = nil

    public init() {}

    private var filteredApps: [DistractingAppItem] {
        if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return screenTime.selectedAppItems
        }
        return screenTime.selectedAppItems.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.category.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    public var body: some View {
        List {
            // MARK: - 1. İzin & Koruma Durumu Kartı
            statusHeaderSection

            // MARK: - 2. Kendi Uygulamalarını Ekle & Hızlı İşlemler
            quickActionsSection

            // MARK: - 3. Seçili / Engellenecek Uygulamalar Listesi
            appListSection
        }
        .searchable(text: $searchQuery, prompt: "Uygulama veya kategori ara...")
        .navigationTitle("Uygulama Engelleme")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    HapticService.shared.selection()
                    showAddCustomAppSheet = true
                }) {
                    Label("Ekle", systemImage: "plus.circle.fill")
                        .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                }
            }
        }
        .sheet(isPresented: $showAddCustomAppSheet) {
            AddCustomAppSheet(screenTime: screenTime)
        }
        .sheet(isPresented: $showShortcutsGuideSheet) {
            ShortcutsLockGuideSheet()
        }
        #if canImport(FamilyControls)
        .familyActivityPicker(isPresented: $showApplePicker, selection: $screenTime.activitySelection)
        #endif
    }

    // MARK: - Durum Başlığı
    private var statusHeaderSection: some View {
        Section(header: Text("KORUMA & İZİN DURUMU")) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(statusColor.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: statusIcon)
                            .font(.system(size: 22))
                            .foregroundColor(statusColor)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(statusTitle)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text(statusSubtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    if isRequestingAuth {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else if screenTime.authStatus == .notDetermined || caseIsRestricted {
                        Button("İzin Ver") {
                            requestPermission()
                        }
                        .font(.system(size: 13, weight: .bold))
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 0.0, green: 0.96, blue: 0.61))
                        .foregroundColor(.black)
                    }
                }

                // Sideloaded / Ücretsiz Apple ID uyarısı ve Akıllı Odak Koruması Butonu
                if caseIsRestricted || !screenTime.isAuthorized {
                    VStack(alignment: .leading, spacing: 10) {
                        Divider().background(Color.white.opacity(0.1))

                        Text("💡 Bilgi: Sideloadly / AltStore ile ücretsiz yüklemede Apple, FamilyControls sistemini kısıtlar. Ancak FOYS Odak Koruması ile oturum başlatabilir ve tüm kilitleri kullanabilirsiniz.")
                            .font(.system(size: 12))
                            .foregroundColor(.orange)

                        HStack(spacing: 10) {
                            Button(action: {
                                screenTime.activateFocusGuardMode()
                            }) {
                                HStack {
                                    Image(systemName: "shield.lefthalf.filled")
                                    Text("Odak Korumasını Aç")
                                }
                                .font(.system(size: 12, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color(red: 0.0, green: 0.96, blue: 0.61))
                                .foregroundColor(.black)
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)

                            Button(action: {
                                showShortcutsGuideSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "arrow.triangle.swap")
                                    Text("Kestirmeler Rehberi")
                                }
                                .font(.system(size: 12, weight: .semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                #if canImport(FamilyControls)
                if screenTime.authStatus == .approved {
                    Button(action: {
                        showApplePicker = true
                    }) {
                        HStack {
                            Image(systemName: "apps.iphone")
                            Text("Apple Sistem Uygulama Seçicisini Aç")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                    }
                    .padding(.top, 4)
                }
                #endif
            }
            .padding(.vertical, 6)
        }
    }

    private var caseIsRestricted: Bool {
        if case .restricted = screenTime.authStatus { return true }
        return false
    }

    private var statusColor: Color {
        switch screenTime.authStatus {
        case .approved: return Color(red: 0.0, green: 0.96, blue: 0.61)
        case .focusGuardActive: return Color(red: 0.0, green: 0.82, blue: 1.0)
        case .restricted: return .orange
        case .notDetermined: return .gray
        }
    }

    private var statusIcon: String {
        switch screenTime.authStatus {
        case .approved: return "checkmark.shield.fill"
        case .focusGuardActive: return "shield.checkered"
        case .restricted: return "exclamationmark.shield.fill"
        case .notDetermined: return "shield.fill"
        }
    }

    private var statusTitle: String {
        switch screenTime.authStatus {
        case .approved: return "Apple Ekran Süresi Aktif"
        case .focusGuardActive: return "FOYS Odak Koruması Aktif"
        case .restricted: return "Apple Kısıtlaması (Sideload)"
        case .notDetermined: return "İzin Bekleniyor"
        }
    }

    private var statusSubtitle: String {
        switch screenTime.authStatus {
        case .approved: return "Uygulamalar sistem seviyesinde kilitlenir."
        case .focusGuardActive: return "Ders sırasında odak modu & masa saati kilit devrede."
        case .restricted: return "Ücretsiz Apple ID kısıtı var. Odak Koruması hazır."
        case .notDetermined: return "İzin ver butonuna dokunun."
        }
    }

    // MARK: - Hızlı İşlemler Butonları
    private var quickActionsSection: some View {
        Section(header: Text("UYGULAMA LİSTESİ YÖNETİMİ")) {
            // 1. Yeni Uygulama Ekle
            Button(action: {
                HapticService.shared.selection()
                showAddCustomAppSheet = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.app.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("+ Kendi Uygulamanı Ekle")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                        Text("Dilediğin mobil oyun, sosyal medya veya alışveriş uygulamasını yaz.")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }

                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 4)

            // 2. Seçim Butonları
            HStack(spacing: 8) {
                Button(action: {
                    HapticService.shared.selection()
                    screenTime.selectAllApps()
                }) {
                    Text("Tümünü Seç (\(screenTime.selectedAppItems.count))")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.08))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)

                Button(action: {
                    HapticService.shared.selection()
                    screenTime.deselectAllApps()
                }) {
                    Text("Tümünü Kaldır")
                        .font(.system(size: 12, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.08))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)

                Button(action: {
                    HapticService.shared.selection()
                    screenTime.removeAllApps()
                }) {
                    Text("Listeyi Temizle")
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(Color.red.opacity(0.15))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }

            if screenTime.selectedAppItems.isEmpty {
                Button("Varsayılan Uygulamaları Yükle") {
                    HapticService.shared.tap()
                    screenTime.resetToDefaults()
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(red: 0.0, green: 0.82, blue: 1.0))
            }
        }
    }

    // MARK: - Uygulama Listesi
    private var appListSection: some View {
        Section(
            header: Text("KİLİTLENECEK UYGULAMALAR (\(screenTime.activeBlockedAppNames.count) SEÇİLİ)"),
            footer: Text("Çalışma oturumu başladığında seçili olan tüm bu uygulamalar hedefe ulaşılana kadar engellenir. Listedeki uygulamaları sağa kaydırarak silebilirsiniz.")
        ) {
            if filteredApps.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "app.badge.checkmark")
                        .font(.system(size: 36))
                        .foregroundColor(.gray)
                    Text("Listede uygulama bulunamadı.")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                    Text("Yukarıdaki '+ Kendi Uygulamanı Ekle' butonuna basarak dilediğin uygulamayı ekleyebilirsin.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                ForEach(filteredApps) { app in
                    Button(action: {
                        HapticService.shared.selection()
                        screenTime.toggleAppSelection(id: app.id)
                    }) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color(hex: app.colorHex).opacity(0.2))
                                    .frame(width: 36, height: 36)

                                Image(systemName: app.iconSystemName)
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(hex: app.colorHex))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(app.name)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.primary)

                                    if app.isCustom {
                                        Text("ÖZEL")
                                            .font(.system(size: 9, weight: .black))
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 2)
                                            .background(Color(red: 0.0, green: 0.96, blue: 0.61).opacity(0.2))
                                            .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                                            .cornerRadius(4)
                                    }
                                }

                                Text(app.category)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            Image(systemName: app.isSelected ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 22))
                                .foregroundColor(app.isSelected ? Color(red: 0.0, green: 0.96, blue: 0.61) : .gray.opacity(0.4))
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            HapticService.shared.tap()
                            screenTime.removeApp(id: app.id)
                        } label: {
                            Label("Sil", systemImage: "trash.fill")
                        }
                    }
                }
            }
        }
    }

    private func requestPermission() {
        isRequestingAuth = true
        HapticService.shared.tap()
        Task {
            _ = await screenTime.requestScreenTimeAuthorization()
            await MainActor.run {
                self.isRequestingAuth = false
            }
        }
    }
}

// MARK: - Kendi Uygulamasını Ekleme Sayfası (Sheet)
public struct AddCustomAppSheet: View {
    @ObservedObject var screenTime: ScreenTimeManager
    @Environment(\.dismiss) private var dismiss

    @State private var appName: String = ""
    @State private var selectedCategory: String = "Sosyal Medya"
    @State private var selectedIcon: String = "gamecontroller.fill"
    @State private var selectedColorHex: String = "#00F59B"

    private let categories = [
        "Sosyal Medya",
        "Oyun",
        "Kısa Video",
        "Video & Dizi",
        "Mesajlaşma",
        "Alışveriş",
        "Özel Uygulama"
    ]

    private let icons = [
        "gamecontroller.fill",
        "camera.circle.fill",
        "play.rectangle.fill",
        "bubble.left.and.bubble.right.fill",
        "cart.fill",
        "tv.fill",
        "flame.fill",
        "heart.fill",
        "globe",
        "message.fill",
        "music.note",
        "star.fill",
        "bolt.fill",
        "sparkles",
        "cross.fill",
        "figure.run",
        "cup.and.saucer.fill",
        "airplane",
        "bag.fill",
        "film.fill",
        "phone.fill",
        "newspaper.fill"
    ]

    private let colors = [
        "#00F59B", // Neon Green
        "#00D2FF", // Cyan
        "#FF3366", // Pink/Red
        "#FF9900", // Orange
        "#A855F7", // Purple
        "#FFD700", // Yellow
        "#3B82F6"  // Blue
    ]

    public var body: some View {
        NavigationStack {
            Form {
                // 1. Uygulama Adı
                Section(header: Text("UYGULAMA ADI")) {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(hex: selectedColorHex).opacity(0.2))
                                .frame(width: 36, height: 36)
                            Image(systemName: selectedIcon)
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: selectedColorHex))
                        }

                        TextField("Örn: Brawl Stars, Twitter, Discord...", text: $appName)
                            .font(.system(size: 15))
                    }
                }

                // 2. Kategori Seçimi
                Section(header: Text("KATEGORİ")) {
                    Picker("Kategori", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                }

                // 3. Simge Seçimi
                Section(header: Text("SİMGE SEÇİN")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                        ForEach(icons, id: \.self) { icon in
                            Button(action: {
                                selectedIcon = icon
                                HapticService.shared.selection()
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedIcon == icon ? Color(hex: selectedColorHex).opacity(0.3) : Color.white.opacity(0.06))
                                        .frame(height: 40)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedIcon == icon ? Color(hex: selectedColorHex) : Color.clear, lineWidth: 1.5)
                                        )

                                    Image(systemName: icon)
                                        .font(.system(size: 18))
                                        .foregroundColor(selectedIcon == icon ? Color(hex: selectedColorHex) : .gray)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // 4. Renk Seçimi
                Section(header: Text("RENK SEÇİN")) {
                    HStack(spacing: 14) {
                        ForEach(colors, id: \.self) { hex in
                            Button(action: {
                                selectedColorHex = hex
                                HapticService.shared.selection()
                            }) {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: selectedColorHex == hex ? 3 : 0)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Yeni Uygulama Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        saveApp()
                    }
                    .disabled(appName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .fontWeight(.bold)
                }
            }
        }
    }

    private func saveApp() {
        HapticService.shared.quizSuccess()
        screenTime.addCustomApp(
            name: appName,
            category: selectedCategory,
            iconSystemName: selectedIcon,
            colorHex: selectedColorHex
        )
        dismiss()
    }
}

// MARK: - iOS Kestirmeler (Shortcuts) Otomasyon Rehberi Sheet
public struct ShortcutsLockGuideSheet: View {
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    // Üst Banner
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(LinearGradient(colors: [Color(red: 0.0, green: 0.82, blue: 1.0).opacity(0.2), Color(red: 0.0, green: 0.96, blue: 0.61).opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))

                        HStack(spacing: 14) {
                            Image(systemName: "arrow.triangle.swap")
                                .font(.system(size: 32))
                                .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))

                            VStack(alignment: .leading, spacing: 4) {
                                Text("iOS Kestirmeler ile Kesin Kilit")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                Text("Ücretsiz sideload yapıldığında bile Instagram açıldığında FOYS'a yönlendirir!")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(16)
                    }

                    Text("3 Kolay Adımda Kurulum")
                        .font(.system(size: 18, weight: .heavy))
                        .foregroundColor(.white)

                    guideStep(
                        step: "1",
                        title: "Kestirmeler Uygulamasını Açın",
                        desc: "iPhone'unuzdaki 'Kestirmeler' (Shortcuts) uygulamasını açın ve alt kısımdan 'Otomasyon' sekmesine geçin."
                    )

                    guideStep(
                        step: "2",
                        title: "Yeni Otomasyon Oluşturun",
                        desc: "'+' butonuna basıp 'Uygulama'yı seçin. Kilitlemek istediğiniz uygulamaları (Instagram, TikTok, Oyunlar) seçin. 'Açıldığında' ve 'Hemen Çalıştır' seçeneklerini işaretleyin."
                    )

                    guideStep(
                        step: "3",
                        title: "FOYS'a Yönlendirme Ekleyin",
                        desc: "Yeni Boş Otomasyon -> İşlem Ekle -> 'URL'yi Aç' seçin ve URL olarak şunu yapıştırın: foys://"
                    )

                    // URL Kopyalama Kutusu
                    HStack {
                        Text("foys://")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))

                        Spacer()

                        Button(action: {
                            UIPasteboard.general.string = "foys://"
                            HapticService.shared.tap()
                        }) {
                            Text("URL'yi Kopyala")
                                .font(.system(size: 13, weight: .bold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(red: 0.0, green: 0.96, blue: 0.61))
                                .foregroundColor(.black)
                                .cornerRadius(6)
                        }
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(10)
                }
                .padding(20)
            }
            .navigationTitle("Kestirmeler Otomasyonu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tamam") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func guideStep(step: String, title: String, desc: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.0, green: 0.96, blue: 0.61))
                    .frame(width: 28, height: 28)
                Text(step)
                    .font(.system(size: 14, weight: .black))
                    .foregroundColor(.black)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Color Hex Yardımcısı
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 245, 155)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
