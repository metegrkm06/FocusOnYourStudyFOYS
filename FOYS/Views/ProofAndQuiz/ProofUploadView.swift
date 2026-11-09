import SwiftUI
import PhotosUI

/// Ders Çalışma Kanıtı Fotoğrafı Yükleme Sayfası
public struct ProofUploadView: View {
    @ObservedObject var sessionVM: StudySessionViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var isShowingCamera: Bool = false
    @State private var errorMessage: String? = nil

    public init(sessionVM: StudySessionViewModel) {
        self.sessionVM = sessionVM
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.07, blue: 0.11).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // 1. Bilgilendirme Kartı
                        infoInstructionBanner

                        // 2. Fotoğraf Önizleme veya Seçim Alanı
                        photoPreviewOrPickerBox

                        // 3. Kamera veya Galeriden Seçim Butonları
                        selectionActionButtons

                        // 4. Doğrula & Testi Başlat Butonu
                        if let image = selectedImage {
                            GlowButton(
                                title: sessionVM.isGeneratingQuiz ? "Yapay Zeka İnceliyor..." : "Yapay Zekaya Gönder & Sınavı Başlat",
                                icon: "sparkles",
                                gradientColors: [Color(red: 0.0, green: 0.96, blue: 0.61), Color(red: 0.0, green: 0.82, blue: 1.0)],
                                height: 56,
                                isLoading: sessionVM.isGeneratingQuiz
                            ) {
                                Task {
                                    await sessionVM.submitProofImage(image)
                                }
                            }
                            .padding(.top, 10)
                        }

                        // 5. Hata Mesajı (Varsa)
                        if let err = errorMessage {
                            Text(err)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Çalışma Kanıtı")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
            }
            .onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            self.selectedImage = uiImage
                            self.errorMessage = nil
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingCamera) {
                CameraPickerWrapper(image: $selectedImage)
            }
        }
    }

    // MARK: - Bilgilendirme
    private var infoInstructionBanner: some View {
        GlassContainer(cornerRadius: 18) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 20))
                        .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                    Text("Ders Notu / Kitap Kanıtı")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                }

                Text("Çalıştığın \(sessionVM.currentSession.subject) - \(sessionVM.currentSession.topic) konusuna ait tuttuğun notların veya çözdüğün soruların fotoğrafını yükle. Yapay zeka fotoğrafı inceleyip sana konudan 3 soru soracak.")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .lineSpacing(3)
            }
            .padding(16)
        }
    }

    // MARK: - Fotoğraf Önizleme Kutusu
    private var photoPreviewOrPickerBox: some View {
        ZStack {
            if let img = selectedImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color(red: 0.0, green: 0.96, blue: 0.61), lineWidth: 2)
                    )
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)

                    Text("Fotoğraf Henüz Seçilmedi")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)

                    Text("Aşağıdan kamerayı aç veya galeriden seç")
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.8))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.1), style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                )
            }
        }
    }

    // MARK: - Kamera & Galeri Butonları
    private var selectionActionButtons: some View {
        HStack(spacing: 12) {
            // Kamera Butonu
            Button(action: {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    isShowingCamera = true
                } else {
                    errorMessage = "Cihazda kamera kullanılamıyor (Simülatör modunda galeri kullanınız)."
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "camera.fill")
                    Text("Fotoğraf Çek")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            // Galeri Butonu
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                HStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle")
                    Text("Galeriden Seç")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color(red: 0.0, green: 0.96, blue: 0.61))
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(Color(red: 0.0, green: 0.96, blue: 0.61).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }
}

/// SwiftUI Kamera Seçici Köprüsü
struct CameraPickerWrapper: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerWrapper
        init(_ parent: CameraPickerWrapper) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[.originalImage] as? UIImage {
                parent.image = img
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
