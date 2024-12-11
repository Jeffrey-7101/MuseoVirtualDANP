import SwiftUI

struct ExposicionDetalleView: View {
    let exposicion: Exposicion
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
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
            }
            .padding()
        }
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
