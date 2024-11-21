//
//  ExposicionesView.swift
//  MuseoVirtualDANP
//
//  Created by MacEpis on 22/10/24.
//

import SwiftUI

struct ExposicionesView: View {
    @StateObject private var viewModel = FoodListViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.exposiciones) { exposicion in
                        NavigationLink(destination: ExposicionDetalleView(exposicion: exposicion)) {
                            ExposicionRow(exposicion: exposicion)
                                .onAppear {
                                    if exposicion.id == viewModel.exposiciones.last?.id {
                                        viewModel.loadMoreExposiciones()
                                    }
                                }
                        }
                    }
                    
                    // Indicador de carga si está cargando
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Exposiciones")
            .onAppear {
                // Cargar datos si la lista inicialmente está vacía
                if viewModel.exposiciones.isEmpty {
                    viewModel.loadMoreExposiciones()
                }
            }
        }
    }
}


struct ExposicionRow: View {
    let exposicion: FoodData
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Imagen usando AsyncImage para cargar desde URL
            if let imageUrl = URL(string: exposicion.imagen ?? "") {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        // Placeholder mientras se carga la imagen
                        ProgressView()
                            .frame(width: 60, height: 60)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                    case .failure:
                        // Icono de error si falla la carga de la imagen
                        Image(systemName: "photo.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // Icono si no hay URL de imagen
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)
            }

            // Información de la exposición
            VStack(alignment: .leading, spacing: 8) {
                Text(exposicion.titulo)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Tecnica: \(exposicion.tecnica)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "tag.fill")
                        .foregroundColor(.blue)
                    Text(exposicion.categoria)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.green)
                    Text("Año: \(exposicion.ano)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(exposicion.descripcion)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color(hex: exposicion.bg_color).opacity(0.1))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 4)
    }
}


extension Color {
    init(hex: String, alpha: CGFloat) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB 12bit
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB 24bit
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xF, int & 0xF)
        case 8: // RGB 32bit
            (a, r, g, b) = (int >> 24, int >> 16 & 0xF, int >> 8 & 0xF, int & 0xF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r)/255,
            green: Double(g)/255,
            blue: Double(b)/255,
            opacity: Double(a)/255
        )
    }
}
