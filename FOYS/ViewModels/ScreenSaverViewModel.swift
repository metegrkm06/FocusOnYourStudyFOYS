import SwiftUI
import Combine

/// Masa Saati & Always-On Ekran Koruyucu Modu ViewModel'i
@MainActor
public final class ScreenSaverViewModel: ObservableObject {
    @Published public var currentTimeString: String = ""
    @Published public var currentDateString: String = ""
    @Published public var currentQuote: String = ""
    @Published public var isDimmed: Bool = false

    private var clockTimer: AnyCancellable?
    private var quoteIndex: Int = 0

    private let quotes: [String] = [
        "Bugün yaptığın fedakarlıklar, yarın yaşayacağın gururun temelidir.",
        "Zorluklar, başarının değerini artıran süslerdir.",
        "Dikkatin dağılmak istediğinde hatırla: Hedefine bir adım daha yaklaştın.",
        "Yorulunca dinlenmeyi öğren, vazgeçmeyi değil.",
        "Gelecek, bugünden ona hazırlananlara aittir.",
        "Disiplin, ne istediğini bilmek ile o an ne hissettiğin arasındaki tercihtir.",
        "Yarım saatlik derin odaklanma, 3 saatlik dağınık çalışmadan kat kat üstündür.",
        "Kendine inan. Bugün çözemediğin sorular, yarın en büyük gücün olacak."
    ]

    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "tr_TR")
        f.dateFormat = "d MMMM EEEE"
        return f
    }()

    public init() {
        updateTime()
        currentQuote = quotes.first ?? ""
    }

    public func activateScreenSaver() {
        // Ekranın otomatik kapanmasını engelle (Masa saati modunda açık kalsın)
        UIApplication.shared.isIdleTimerDisabled = true

        updateTime()
        clockTimer?.cancel()
        clockTimer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTime()
            }
    }

    public func deactivateScreenSaver() {
        // Ekran koruyucudan çıkınca normal uyku moduna geri dön
        UIApplication.shared.isIdleTimerDisabled = false
        clockTimer?.cancel()
        clockTimer = nil
    }

    private func updateTime() {
        let now = Date()
        currentTimeString = timeFormatter.string(from: now)
        currentDateString = dateFormatter.string(from: now)

        // Her 60 saniyede bir motivasyon sözünü güncelle
        let seconds = Calendar.current.component(.second, from: now)
        if seconds == 0 {
            quoteIndex = (quoteIndex + 1) % quotes.count
            currentQuote = quotes[quoteIndex]
        }
    }

    public func toggleDim() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDimmed.toggle()
        }
    }
}
