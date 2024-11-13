//
// ExposicionDetalleView.swift

import SwiftUI

struct ExposicionDetalleView: View {
    let exposicion: ExposicionDate

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Imagen de la exposición
                if let imageUrl = URL(string: exposicion.imagen ?? "") {
                    AsyncImage(url: imageUrl) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
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
                                .frame(height: 200)
                                .foregroundColor(.gray)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(8)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                Text("Técnica: \(exposicion.tecnica)")
                    .font(.headline)
                
                Text("Categoría: \(exposicion.categoria)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("Año: \(exposicion.ano)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(exposicion.descripcion)
                    .font(.body)
                    .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle(exposicion.titulo)
    }
}
