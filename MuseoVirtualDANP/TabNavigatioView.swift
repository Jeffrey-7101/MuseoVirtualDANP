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

                // Segunda pestaña - QR
                NavigationView {
                    HomeView(isLoggedIn: $isloggedIn)
                }
                .tabItem {
                    Image(systemName: "qrcode.viewfinder")
                    Text("QR")
                }

                // Tercera pestaña - Mapa
                NavigationView {
                    MuseumMapView(rooms: [
                        MuseumRoom(name: "Sala 1", frame: CGRect(x: 50, y: 100, width: 150, height: 150), expositions: [
                            Exposition(name: "Pintura A", shape: .circle, relativeFrame: CGRect(x: 30, y: 30, width: 40, height: 40)), // Coordenadas relativas a la sala
                            Exposition(name: "Pintura B", shape: .rectangle, relativeFrame: CGRect(x: -20, y: 0, width: 10, height: 20))
                        ]),
                        MuseumRoom(name: "Sala 2", frame: CGRect(x: 250, y: 100, width: 150, height: 150), expositions: [
                            Exposition(name: "Pintura C", shape: .rectangle, relativeFrame: CGRect(x: 20, y: 50, width: 50, height: 30)),
                            Exposition(name: "Pintura D", shape: .circle, relativeFrame: CGRect(x: 90, y: 90, width: 40, height: 40))
                        ]),
                        MuseumRoom(name: "Sala 3", frame: CGRect(x: 150, y: 300, width: 150, height: 150), expositions: [
                            Exposition(name: "Pintura E", shape: .circle, relativeFrame: CGRect(x: 40, y: 50, width: 50, height: 50)),
                            Exposition(name: "Pintura F", shape: .rectangle, relativeFrame: CGRect(x: 100, y: 100, width: 60, height: 40))
                        ])
                    ], targetSize: CGSize(width: 400, height: 600))
                }
                .tabItem {
                    Image(systemName: "map")
                    Text("Mapa")
                }
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
