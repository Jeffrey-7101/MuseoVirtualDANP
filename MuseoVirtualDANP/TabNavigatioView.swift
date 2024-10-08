//
//  TabNavigatioView.swift
//  MuseoVirtualDANP
//
//  Created by MacEpis on 5/10/24.
//

import SwiftUI


struct TabNavigatioView: View {
    @Binding var isloggedIn: Bool
        
        var body: some View {
            TabView {
                // Primera pestaña - Listado
                ListadoView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Listado")
                    }
                
                // Segunda pestaña - QR
                HomeView(isLoggedIn: $isloggedIn)
                    .tabItem {
                        Image(systemName: "qrcode.viewfinder")
                        Text("QR")
                    }
                
                // Tercera pestaña - Mapa
                // Tercera pestaña - Mapa
                            VStack {
                                MuseumMapView(targetSize: CGSize(width: 300, height: 640))
                                    .frame(maxHeight: .infinity) // Asegura que el contenido respete el área segura inferior
                                Spacer() // Empuja el contenido hacia arriba, respetando la barra de pestañas
                            }
                            .tabItem {
                                Image(systemName: "map")
                                Text("Mapa")
                            }
            }
            .onAppear {
                // Ocultar la barra de navegación en toda la aplicación
                UINavigationBar.appearance().isHidden = true
            }
            .onDisappear {
                // Restaurar la barra de navegación si es necesario cuando esta vista desaparece
                UINavigationBar.appearance().isHidden = false
            }
        }
    }
    struct ListadoView: View {
        var body: some View {
            List {
                Text("Elemento 1")
                Text("Elemento 2")
                Text("Elemento 3")
            }
            .navigationTitle("Listado")
        }
    }

