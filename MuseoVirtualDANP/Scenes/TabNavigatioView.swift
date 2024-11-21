import SwiftUI

struct TabNavigatioView: View {
    @Binding var isloggedIn: Bool
        
        var body: some View {
            TabView {
                // Primera pestaña - Listado
                FoodListView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Listado")
                    }
                
                
//                QRScannerView()
//                    .tabItem {
//                         Image(systemName: "qrcode.viewfinder")
//                        Text("QR")
//                      }
                
                HomeView(isLoggedIn: $isloggedIn)
                    .tabItem {
                        Image(systemName: "qrcode.viewfinder")
                        Text("QR")
                    }
                
//                 Tercera pestaña
                    VStack {
                    DashboardView()
//                    Spacer()
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

