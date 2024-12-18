import SwiftUI

// Vista Principal
struct ExposicionesView: View {
    @StateObject private var viewModel = ExposicionesViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) { // Espaciado uniforme entre elementos
                    ForEach(viewModel.exposiciones) { exposicion in
                        NavigationLink(destination: ExposicionDetalleView(exposicionId: exposicion.id)) {
                            ExposicionRow(exposicion: exposicion)
                                .onAppear {
                                    if exposicion.id == viewModel.exposiciones.last?.id {
                                        viewModel.loadMoreExposiciones()
                                    }
                                }
                        }
                    }
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .padding(.horizontal, 16) // Márgenes laterales
            }
            .navigationTitle("Exposiciones")
            .navigationBarTitleDisplayMode(.inline) // Diseño compacto
            .onAppear {
                if viewModel.exposiciones.isEmpty {
                    viewModel.loadMoreExposiciones()
                }
            }
        }
    }
}

// Fila para cada exposición
struct ExposicionRow: View {
    let exposicion: Exposicion
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: URL(string: exposicion.imagen ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 80, height: 80)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(hex: exposicion.border_color, alpha: 1.0), lineWidth: exposicion.border ? 2 : 0))
                case .failure:
                    Image(systemName: "photo.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            
            VStack(alignment: .leading, spacing: 4) { // Espaciado interno
                Text(exposicion.titulo)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Técnica: \(exposicion.tecnica)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Categoría: \(exposicion.categoria)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Año: \(exposicion.ano)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: exposicion.bg_color, alpha: 0.2))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
    }
}

// Extensión de Color para Hex
extension Color {
    init(hex: String, alpha: CGFloat = 1.0) {
        let hex = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hex)
        var hexNumber: UInt64 = 0
        scanner.scanHexInt64(&hexNumber)
        let r, g, b: Double
        if hex.count == 6 {
            r = Double((hexNumber & 0xFF0000) >> 16) / 255
            g = Double((hexNumber & 0x00FF00) >> 8) / 255
            b = Double(hexNumber & 0x0000FF) / 255
        } else {
            r = 0
            g = 0
            b = 0
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: Double(alpha))
    }
}
