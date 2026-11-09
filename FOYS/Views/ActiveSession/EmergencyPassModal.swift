import SwiftUI

/// 3 Dakikalık Acil Durum İzni Modalı
public struct EmergencyPassModal: View {
    @ObservedObject var sessionVM: StudySessionViewModel

    public init(sessionVM: StudySessionViewModel) {
        self.sessionVM = sessionVM
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.85).ignoresSafeArea()

            VStack(spacing: 24) {
                // İkon
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 88, height: 88)

                    Image(systemName: "hourglass")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.orange)
                }

                VStack(spacing: 8) {
                    Text("3 Dakikalık Acil İzin Aktif")
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundColor(.white)

                    Text("Önemli bir işin varsa hallet. Süre bittiğinde kalkan otomatik olarak tekrar devreye girecek.")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                // Geri Sayım Sayacı
                Text(sessionVM.currentSession.formattedEmergencyTime)
                    .font(.system(size: 48, weight: .black, design: .monospaced))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.orange.opacity(0.12))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.orange.opacity(0.4), lineWidth: 1.5)
                    )

                // Erken Bitir Butonu
                Button(action: {
                    sessionVM.endEmergencyPassEarly()
                }) {
                    Text("İşimi Bitirdim, Tekrar Kilitle")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.white.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal, 20)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(red: 0.08, green: 0.11, blue: 0.17))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1.5)
            )
            .padding(24)
        }
    }
}
