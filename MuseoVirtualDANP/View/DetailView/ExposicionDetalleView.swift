import SwiftUI
import AVKit

struct ExposicionDetalleView: View {
    let exposicionId: Int?
    @StateObject private var viewModel = ExposicionDetalleViewModel()
    @StateObject private var audioPlayer = AudioPlayerViewModel()
    
    var body: some View {
        if let exposicionId = exposicionId {
            Group {
                if let exposicion = viewModel.exposicion {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Imagen de la exposición
                            AsyncImage(url: URL(string: exposicion.imagen ?? "")) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                        .aspectRatio(1, contentMode: .fit)
                                        .background(Color.gray.opacity(0.3))
                                        .cornerRadius(8)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(8)
                                case .failure:
                                    Image(systemName: "photo.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            
                            // Información de la exposición
                            Text(exposicion.titulo)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("Técnica: \(exposicion.tecnica)")
                                .font(.title3)
                            
                            Text("Categoría: \(exposicion.categoria)")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            Text("Descripción:")
                                .font(.headline)
                            
                            Text(exposicion.descripcion)
                                .font(.body)
                            
                            // Reproductor de audio
                            if let audioURL = exposicion.audio {
                                VStack(spacing: 16) {
                                    Text("Audio Relato")
                                        .font(.headline)
                                    
                                    HStack {
                                        Button(action: {
                                            audioPlayer.togglePlayPause()
                                        }) {
                                            Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                                .resizable()
                                                .frame(width: 50, height: 50)
                                                .foregroundColor(audioPlayer.isPlaying ? .red : .green)
                                        }
                                        
                                        Spacer()
                                        
                                        if let currentTime = audioPlayer.currentTimeFormatted,
                                           let duration = audioPlayer.durationFormatted {
                                            Text("\(currentTime) / \(duration)")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    if let progress = audioPlayer.progress {
                                        ProgressView(value: progress)
                                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(8)
                                .onAppear {
                                    audioPlayer.setupPlayer(with: audioURL)
                                }
                                .onDisappear {
                                    audioPlayer.stopPlayback()
                                }
                            } else {
                                Text("No hay audio disponible para esta exposición.")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("Detalle")
                    .navigationBarTitleDisplayMode(.inline)
                } else if viewModel.isLoading {
                    ProgressView("Cargando...")
                } else {
                    Text("Error al cargar la exposición.")
                        .foregroundColor(.red)
                }
            }
            .onAppear {
                viewModel.fetchExposicion(by: exposicionId)
            }
        }
    }
}

class AudioPlayerViewModel: ObservableObject {
    private var player: AVPlayer?
    private var timeObserver: Any?
    
    @Published var isPlaying = false
    @Published var currentTimeFormatted: String?
    @Published var durationFormatted: String?
    @Published var progress: Double?
    @Published var errorMessage: String?
    
    func setupPlayer(with urlString: String) {
        print("Configurando reproductor con URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            errorMessage = "URL no válida."
            print("Error: URL no válida.")
            return
        }
        
        player = AVPlayer(url: url)
        
        guard let player = player else {
            errorMessage = "No se pudo inicializar el reproductor."
            print("Error: No se pudo inicializar el reproductor.")
            return
        }
        
        // Configurar para que el audio se reproduzca en bucle
        player.actionAtItemEnd = .none
        
        // Escuchar el final del audio
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(restartAudio),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem
        )
        
        // Observa el tiempo de reproducción
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
            guard let self = self, let duration = player.currentItem?.duration else { return }
            
            self.currentTimeFormatted = self.formatTime(time)
            self.durationFormatted = self.formatTime(duration)
            
            let currentTimeSeconds = CMTimeGetSeconds(time)
            let durationSeconds = CMTimeGetSeconds(duration)
            if durationSeconds.isFinite {
                self.progress = currentTimeSeconds / durationSeconds
            }
        }
    }
    
    @objc private func restartAudio() {
        guard let player = player else { return }
        player.seek(to: .zero)
        player.play()
        print("Reproducción reiniciada automáticamente.")
    }
    
    func togglePlayPause() {
        guard let player = player else {
            errorMessage = "El reproductor no está configurado."
            print("Error: El reproductor no está configurado.")
            return
        }
        
        if isPlaying {
            player.pause()
            print("Reproducción pausada.")
        } else {
            player.play()
            print("Reproducción iniciada.")
        }
        isPlaying.toggle()
    }
    
    func stopPlayback() {
        guard let player = player else { return }
        player.pause()
        print("Reproducción detenida y recursos liberados.")
        
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
        }
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        
        self.player = nil
        self.timeObserver = nil
        isPlaying = false
        progress = nil
        currentTimeFormatted = nil
        durationFormatted = nil
    }
    
    private func formatTime(_ time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        guard totalSeconds.isFinite else { return "0:00" }
        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

