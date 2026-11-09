import Foundation
import AVFoundation

/// Çalışırken odaklanmayı artıran ortam sesleri
public enum AmbientSoundType: String, CaseIterable, Identifiable, Sendable {
    case off = "Kapalı"
    case pinkNoise = "Pembe Gürültü (Pink Noise)"
    case alphaWave = "432 Hz Derin Odak Dalgaları"
    case softRain = "Yumuşak Yağmur Ambiyansı"
    case cafeLoFi = "Çalışma Odası Ambiyansı"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .off: return "speaker.slash.fill"
        case .pinkNoise: return "waveform"
        case .alphaWave: return "brain.head.profile"
        case .softRain: return "cloud.rain.fill"
        case .cafeLoFi: return "cup.and.saucer.fill"
        }
    }
}

/// AVAudioEngine tabanlı sentetik odak sesi jeneratörü (harici MP3 indirmeye gerek kalmadan çalışır)
public final class AmbientSoundService: ObservableObject, @unchecked Sendable {
    public static let shared = AmbientSoundService()

    @Published public var currentSound: AmbientSoundType = .off
    @Published public var isPlaying: Bool = false
    @Published public var volume: Float = 0.5 {
        didSet {
            playerNode?.volume = volume
        }
    }

    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?
    private var audioBuffer: AVAudioPCMBuffer?

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("FOYS Ambient Audio Session error: \(error)")
        }
    }

    public func setSound(_ sound: AmbientSoundType) {
        if currentSound == sound && isPlaying {
            stop()
            return
        }

        currentSound = sound
        if sound == .off {
            stop()
        } else {
            play(sound: sound)
        }
    }

    private func play(sound: AmbientSoundType) {
        stop()

        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        engine.attach(player)

        let sampleRate = 44100.0
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let bufferLength = AVAudioFrameCount(sampleRate * 4.0) // 4 saniyelik döngü bufferı

        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bufferLength) else { return }
        buffer.frameLength = bufferLength

        guard let left = buffer.floatChannelData?[0],
              let right = buffer.floatChannelData?[1] else { return }

        // Sentetik ses üretimi
        switch sound {
        case .pinkNoise:
            var b0 = 0.0, b1 = 0.0, b2 = 0.0, b3 = 0.0, b4 = 0.0, b5 = 0.0, b6 = 0.0
            for i in 0..<Int(bufferLength) {
                let white = Double.random(in: -1.0...1.0)
                b0 = 0.99886 * b0 + white * 0.0555179
                b1 = 0.99332 * b1 + white * 0.0750759
                b2 = 0.96900 * b2 + white * 0.1538520
                b3 = 0.86650 * b3 + white * 0.3104856
                b4 = 0.55000 * b4 + white * 0.5329522
                b5 = -0.7616 * b5 - white * 0.0168980
                let pink = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362) * 0.06
                b6 = white * 0.115926
                left[i] = Float(pink)
                right[i] = Float(pink)
            }

        case .alphaWave:
            // 432 Hz ve 442 Hz (10 Hz Alpha Binaural Beat)
            let freqL = 432.0
            let freqR = 442.0
            for i in 0..<Int(bufferLength) {
                let time = Double(i) / sampleRate
                let valL = sin(2.0 * .pi * freqL * time) * 0.12
                let valR = sin(2.0 * .pi * freqR * time) * 0.12
                left[i] = Float(valL)
                right[i] = Float(valR)
            }

        case .softRain:
            for i in 0..<Int(bufferLength) {
                let time = Double(i) / sampleRate
                let swell = (sin(2.0 * .pi * 0.3 * time) + 1.2) * 0.5
                let drop = Double.random(in: -0.15...0.15) * swell
                left[i] = Float(drop)
                right[i] = Float(drop * 0.95)
            }

        case .cafeLoFi:
            for i in 0..<Int(bufferLength) {
                let time = Double(i) / sampleRate
                let lofi = sin(2.0 * .pi * 216.0 * time) * 0.08 + Double.random(in: -0.04...0.04)
                left[i] = Float(lofi)
                right[i] = Float(lofi)
            }

        case .off:
            break
        }

        engine.connect(player, to: engine.mainMixerNode, format: format)
        player.volume = volume

        do {
            try engine.start()
            player.play()
            player.scheduleBuffer(buffer, at: nil, options: .loops, completionHandler: nil)

            self.audioEngine = engine
            self.playerNode = player
            self.audioBuffer = buffer
            self.isPlaying = true
        } catch {
            print("AudioEngine start error: \(error)")
        }
    }

    public func stop() {
        playerNode?.stop()
        audioEngine?.stop()
        playerNode = nil
        audioEngine = nil
        isPlaying = false
    }
}
