//
//  ExposicionesView.swift
//  MuseoVirtualDANP
//
//  Created by MacEpis on 22/10/24.
//

import SwiftUI

struct ExposicionesView: View {
    @StateObject private var viewModel = ExposicionesViewModel()
    
    var body: some View {
        ScrollView{
            LazyVStack{
                ForEach(viewModel.exposiciones) { exposicion in
                    ExposicionRow(exposicion: exposicion)
                        .onAppear{
                            if exposicion.id == viewModel.exposiciones.last?.id {
                                viewModel.loadMoreExposiciones()
                            }
                        }
                }
                
                // Indicador de carga si esta cargando
                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Exposiciones")
        .onAppear{
            // Carga los datos si inicialmente esta vacia
            if viewModel.exposiciones.isEmpty {
                viewModel.loadMoreExposiciones()
            }
        }
    }
}

struct ExposicionRow: View {
    let exposicion: ExposicionDate
    
    var body: some View {
        HStack{
            
            if let imageName = exposicion.imagen {
                Image(imageName)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(exposicion.titulo)
                    .font(.headline)
                Text("Tecnica: \(exposicion.tecnica)")
                    .font(.subheadline)
                Text("Categoria: \(exposicion.categoria)")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                Text("Año: \(exposicion.ano)")
                    .font(.subheadline)
                Text(exposicion.descripcion)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            //.padding()
            //.background(Color(hex: exposicion.bg_color).opacity(0.1))
            //.cornerRadius(10)
            //.overlay(
                //RoundedRectangle(cornerRadius: 10)
                    //.stroke(Color(hex: exposicion.border_color), lineWidth: 1)
            //)
            //.shadow(color: .gray, radius: 5, x: 0, y:5)
            //.padding([.top, .horizontal])
        }
        .padding(.vertical, 8)
        .cornerRadius(10)
        .background(Color(hex: exposicion.bg_color).opacity(0.1))
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
