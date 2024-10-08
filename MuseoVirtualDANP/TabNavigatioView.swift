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
                NavigationView {
                    ListadoView()
                }
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Listado")
                }
                .navigationViewStyle(.stack) // agrego esto por que salta una advertencia en el debug

                // Segunda pestaña - QR
                NavigationView {
                    HomeView(isLoggedIn: $isloggedIn)
                }
                .tabItem {
                    Image(systemName: "qrcode.viewfinder")
                    Text("QR")
                }.navigationViewStyle(.stack)

                // Tercera pestaña - Mapa
                NavigationView {
//                    MapaView()
                    MuseumMapView(targetSize: CGSize(width: 200, height: 420))
                }
                .tabItem {
                    Image(systemName: "map")
                    Text("Mapa")
                }.navigationViewStyle(.stack)
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

    struct QRView: View {
        var body: some View {
            VStack {
                Text("Aquí se escanearía un código QR")
                Image(systemName: "qrcode")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding()
            }
            .navigationTitle("QR")
        }
    }

    struct MapaView: View {
        var body: some View {
            VStack {
                Text("Aquí se mostraría el mapa interior")
                Image(systemName: "map")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding()
            }
            .navigationTitle("Mapa")
        }
    }
