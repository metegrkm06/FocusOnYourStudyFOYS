# FOYS - Focus On Your Study 🎯📚

**FOYS**, ders çalışırken telefon bağımlılığını ve dikkat dağıtıcı uygulamaları (Instagram, TikTok, YouTube Shorts, X, mobil oyunlar vb.) tamamen ortadan kaldıran, yapay zeka destekli ve ödün vermez bir odaklanma uygulamasıdır.

---

## ⚡ Özellikler

### 1. 🛡️ iOS Ekran Süresi & Uygulama Kalkanı (FamilyControls & ManagedSettings)
- Ders çalışmaya başladığınız anda seçtiğiniz dikkat dağıtıcı uygulamalar sistem seviyesinde kilitlenir.
- **Süreli Mod (Timed)**: 25 Dk Pomodoro, 45 Dk Derin Odak, 60 Dk veya özel süre (15-240 dk) belirleyin. Süre bitince bildirim alırsınız.
- **Süresiz Mod (Indefinite)**: Belirli bir süre sınırı yoktur; siz çalışmanızı bitirip çalışma kanıtınızı yapay zekaya doğrulatana kadar uygulamalar kapalı kalır.

### 2. ⏳ 3 Dakikalık Acil Durum İzni (Emergency Pass)
- Ders süresi boyunca gerçekten acil bir mesaj veya arama için **3 dakikalık geçici kilit açma hakkı**.
- 180 saniyelik canlı geri sayım; son 30 saniyede haptik ve bildirim uyarısı; süre bittiğinde otomatik tekrar kilitleme.

### 3. 📸 Yapay Zeka ile Çalışma Kanıtı Doğrulama
- Ders bitiminde çalışma notlarınızın, çözdüğünüz test sayfalarının veya çalışma masanızın fotoğrafını çekin / yükleyin.
- Hedef sınavınız (YKS TYT/AYT, LGS, KPSS, Üniversite, vb.), sınıfınız ve çalıştığınız konuyu seçin.
- Çoklu yapay zeka görüş modeli (Gemini 1.5 Flash, OpenRouter, NVIDIA NIM, Groq) fotoğrafı inceler ve konuyu teyit eder.

### 4. 🧠 3 Soruluk Kilit Açma Testi & Ceza Sistemi
Yapay zeka çalıştığınız konudan ve notlarınızdan tam **3 adet çoktan seçmeli soru** sorar:
- **3/3 Doğru (Tam Başarı)**: Tebrikler! Tüm uygulamaların kilidi hemen açılır. 🎉
- **1 Yanlış (2/3)**: **+15 Dakika** ek çalışma cezası eklenir ve kilit uzatılır! ⏱️
- **2 Yanlış (1/3)**: **+30 Dakika** ek çalışma cezası eklenir! ⏱️
- **3 Yanlış (0/3)**: **+50 Dakika** ek çalışma cezası eklenir! ⏱️

### 5. ⏰ Masa Saati & Always-On Screensaver Modu
- Telefonu masanıza koyun, ekran **hiç kapanmasın** (`isIdleTimerDisabled = true`).
- Büyük dijital saat (`HH:mm:ss`), seans ilerleme halkası ve motive edici odak sözleri.
- **Ekran Karartma (OLED Dim Mode)**: Ekrana dokunarak parlaklığı %10'a düşürün, gece ders çalışırken pil tasarrufu sağlayın.
- **Sentetik Odak Ambiyansı (Ambient Sound)**: Harici dosya indirmeden gerçek zamanlı sentezlenen Pink Noise, 432 Hz Derin Odak Alfa Dalgaları ve Yağmur Sesi.

### 6. 🔑 Çoklu AI Sağlayıcı Desteği
- **Google Gemini** (Gemini 1.5 Flash - Ücretsiz API Key)
- **OpenRouter** (Llama 3, Qwen, Gemini Flash ücretsiz modelleri)
- **NVIDIA NIM** (build.nvidia.com ücretsiz geliştirici modelleri)
- **Groq Cloud** (Işık hızında LPU çıkarımı)
- **Özel MCP / OpenAI Uyumlu Sunucu** (Yerel Ollama veya özel endpoint)
- **Dahili Çevrimdışı Soru Bankası**: API anahtarı olmasa bile yüzlerce müfredat sorusuyla %100 çevrimdışı çalışabilirlik!

---

## 📲 Sideloadly ile Kurulum (Windows / Mac)

1. Repository'deki **GitHub Actions** sekmesine gidin.
2. En son başarılı **Build FOYS iOS IPA** çalışmasını açın.
3. **Artifacts** bölümünden `FOYS-iOS-IPA` dosyasını indirin ve zipten çıkarın (`FOYS.ipa`).
4. iPhone'unuzu bilgisayara bağlayıp **Sideloadly** uygulamasını açın.
5. `FOYS.ipa` dosyasını Sideloadly'e sürükleyin, Apple ID'nizi girip **Start** butonuna basın.
6. Kurulum bitince iPhone'unuzda `Ayarlar > Genel > VPN ve Aygıt Yönetimi` kısmından profilinize güven verin ve FOYS'u açın!
