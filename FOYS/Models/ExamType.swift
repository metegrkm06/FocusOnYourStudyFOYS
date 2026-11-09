import Foundation

/// Sınav ve eğitim hedefleri
public enum ExamType: String, CaseIterable, Identifiable, Codable, Sendable {
    case yksTyt = "YKS - TYT (Temel Yeterlilik)"
    case yksAyt = "YKS - AYT (Alan Yeterlilik)"
    case lgs = "LGS (Liselere Geçiş)"
    case kpss = "KPSS (Kamu Personeli)"
    case ales = "ALES / DGS"
    case tus = "TUS (Tıpta Uzmanlık)"
    case university = "Üniversite (Vize / Final)"
    case highSchool = "Lise Dersleri (9-12. Sınıf)"
    case middleSchool = "Ortaokul Dersleri (5-8. Sınıf)"
    case language = "Yabancı Dil (YDS / IELTS / TOEFL)"
    case general = "Genel / Bireysel Çalışma"

    public var id: String { rawValue }

    public var shortTitle: String {
        switch self {
        case .yksTyt: return "TYT"
        case .yksAyt: return "AYT"
        case .lgs: return "LGS"
        case .kpss: return "KPSS"
        case .ales: return "ALES"
        case .tus: return "TUS"
        case .university: return "Üniversite"
        case .highSchool: return "Lise"
        case .middleSchool: return "Ortaokul"
        case .language: return "Yabancı Dil"
        case .general: return "Genel"
        }
    }

    public var iconName: String {
        switch self {
        case .yksTyt, .yksAyt: return "graduationcap.fill"
        case .lgs: return "backpack.fill"
        case .kpss: return "building.columns.fill"
        case .ales: return "chart.bar.doc.horizontal.fill"
        case .tus: return "cross.case.fill"
        case .university: return "building.2.fill"
        case .highSchool: return "book.closed.fill"
        case .middleSchool: return "pencil.and.ruler.fill"
        case .language: return "globe.europe.africa.fill"
        case .general: return "flame.fill"
        }
    }

    public var defaultGradeLevels: [String] {
        switch self {
        case .yksTyt, .yksAyt:
            return ["12. Sınıf", "Mezun"]
        case .lgs:
            return ["8. Sınıf"]
        case .kpss:
            return ["Lisans", "Ön Lisans", "Ortaöğretim"]
        case .ales, .tus:
            return ["Lisansüstü", "Mezun"]
        case .university:
            return ["1. Sınıf", "2. Sınıf", "3. Sınıf", "4. Sınıf", "Yüksek Lisans"]
        case .highSchool:
            return ["9. Sınıf", "10. Sınıf", "11. Sınıf", "12. Sınıf"]
        case .middleSchool:
            return ["5. Sınıf", "6. Sınıf", "7. Sınıf", "8. Sınıf"]
        case .language, .general:
            return ["Başlangıç (A1-A2)", "Orta (B1-B2)", "İleri (C1-C2)", "Genel"]
        }
    }

    public var defaultSubjects: [String] {
        switch self {
        case .yksTyt:
            return ["Temel Matematik", "Geometri", "Türkçe (Paragraf & Dil)", "Fizik", "Kimya", "Biyoloji", "Tarih", "Coğrafya", "Felsefe & Din"]
        case .yksAyt:
            return ["AYT Matematik", "AYT Geometri", "AYT Fizik", "AYT Kimya", "AYT Biyoloji", "Edebiyat", "Tarih-1", "Coğrafya-1", "Tarih-2", "Coğrafya-2", "Felsefe Grubu"]
        case .lgs:
            return ["LGS Matematik", "LGS Fen Bilimleri", "LGS Türkçe", "T.C. İnkılap Tarihi", "Din Kültürü", "İngilizce"]
        case .kpss:
            return ["Genel Yetenek Matematik", "Genel Yetenek Türkçe", "Tarih", "Türkiye Coğrafyası", "Vatandaşlık & Güncel", "Eğitim Bilimleri", "Alan Bilgisi"]
        case .ales:
            return ["Sayısal Mantık & Matematik", "Sözel Mantık & Paragraf"]
        case .tus:
            return ["Temel Tıp Bilimleri", "Klinik Tıp Bilimleri", "Anatomi", "Fizyoloji", "Farmakoloji", "Patoloji", "Dahiliye", "Pediatri", "Genel Cerrahi"]
        case .university:
            return ["Kalkülüs / Matematik", "Lineer Cebir", "Fizik", "Programlama / Yazılım", "Hukuk", "Mikroekonomi", "Makroekonomi", "Organik Kimya", "Veri Yapıları"]
        case .highSchool:
            return ["Matematik", "Fizik", "Kimya", "Biyoloji", "Türk Dili ve Edebiyatı", "Tarih", "Coğrafya", "İngilizce", "Almanca"]
        case .middleSchool:
            return ["Matematik", "Fen Bilimleri", "Türkçe", "Sosyal Bilgiler", "İngilizce", "Din Kültürü"]
        case .language:
            return ["İngilizce Kelime (Vocabulary)", "Gramer (Grammar)", "Reading (Okuma)", "Listening (Dinleme)", "Writing (Yazma)", "Speaking (Konuşma)"]
        case .general:
            return ["Kitap Okuma", "Yazılım / Kodlama", "Proje Geliştirme", "Yabancı Dil", "Kişisel Gelişim", "Mesleki Eğitim"]
        }
    }
}
