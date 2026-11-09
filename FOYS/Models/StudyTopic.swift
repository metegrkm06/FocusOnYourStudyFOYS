import Foundation

/// Ders konuları ve önerilen popüler konu listeleri
public struct StudyTopic: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let name: String
    public let subject: String

    public init(name: String, subject: String) {
        self.id = "\(subject)-\(name)"
        self.name = name
        self.subject = subject
    }

    /// Konu önerileri sunan yardımcı fonksiyon
    public static func suggestedTopics(for subject: String) -> [String] {
        let normalized = subject.lowercased()
        if normalized.contains("matematik") {
            if normalized.contains("ayt") {
                return ["Türev ve Uygulamaları", "İntegral ve Alan", "Limit ve Süreklilik", "Trigonometri", "Polinomlar & 2. Dereceden Denklemler", "Logaritma & Diziler", "Olasılık & Permütasyon"]
            } else {
                return ["Temel Kavramlar & Sayılar", "Bölme & Bölünebilme & EBOB-EKOK", "Üslü & Köklü Sayılar", "Problemler (Hız, Yaş, Yüzde)", "Kümeler & Fonksiyonlar", "Oran & Orantı", "Çarpanlara Ayırma"]
            }
        } else if normalized.contains("geometri") {
            return ["Üçgende Açılar ve Kenarlar", "Özel Üçgenler (30-60-90)", "Çember ve Daire", "Analitik Geometri", "Katı Cisimler (Prizma, Koni, Küre)", "Dörtgenler ve Çokgenler"]
        } else if normalized.contains("fizik") {
            return ["Newton Hareket Yasaları", "Elektrik ve Manyetizma", "Optik & Dalgalar", "İş, Güç ve Enerji", "Basit Harmonik Hareket", "Madde ve Özellikleri", "Modern Fizik"]
        } else if normalized.contains("kimya") {
            return ["Mol Kavramı & Hesaplamalar", "Periyodik Sistem ve Atom", "Kimyasal Denge & Hız", "Asitler, Bazlar ve Tuzlar", "Organik Kimyaya Giriş", "Elektrokimya & Piller"]
        } else if normalized.contains("biyoloji") {
            return ["Hücre ve Organelleri", "Mitoz & Mayoz Bölünme", "Kalıtım ve Genetik", "Fotosentez ve Hücresel Solunum", "İnsan Fizyolojisi & Sistemler", "Ekoloji ve Madde Döngüleri"]
        } else if normalized.contains("türkçe") || normalized.contains("edebiyat") {
            return ["Paragrafta Anlam ve Taktikler", "Sözcükte ve Cümlede Anlam", "Yazım Kuralları ve Noktalama", "Cümle Öğeleri ve Fiilimsiler", "Divan Edebiyatı", "Tanzimat ve Cumhuriyet Dönemi"]
        } else if normalized.contains("tarih") {
            return ["İlk ve Orta Çağda Türk Dünyası", "Osmanlı Devleti Kuruluş & Yükselme", "Milli Mücadele ve Kurtuluş Savaşı", "Atatürk İlkeleri ve İnkılaplar", "20. Yüzyıl Başlarında Dünya"]
        } else if normalized.contains("coğrafya") {
            return ["Dünyanın Şekli ve Hareketleri", "İklim Tipleri ve Türkiye'nin İklimi", "Harita Bilgisi ve Koordinatlar", "Nüfus ve Yerleşme", "Türkiye'nin Doğal Kaynakları"]
        } else if normalized.contains("yazılım") || normalized.contains("programlama") {
            return ["Veri Yapıları ve Algoritmalar", "Nesne Yönelimli Programlama (OOP)", "Swift & iOS Geliştirme", "Python & Makine Öğrenimi", "SQL ve Veritabanı Tasarımı", "Web Frontend & Backend"]
        } else if normalized.contains("ingilizce") {
            return ["Academic Vocabulary (50 Kelime)", "Tenses & Conditionals", "Reading Comprehension (Reading)", "IELTS/TOEFL Writing Task 2", "Phrasal Verbs & Idioms"]
        } else {
            return ["Konu Özeti & Not Çıkarma", "Soru Bankası & Test Çözümü", "Deneme Sınavı Analizi", "Yanlış Yapılan Soruları İnceleme", "Formül & Kavram Tekrarı"]
        }
    }
}
