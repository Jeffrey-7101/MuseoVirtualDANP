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
            
            // Segunda pestaña - Home
            HomeView(isLoggedIn: $isloggedIn)
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Home")
                }
            
            // Tercera pestaña - Estadísticas
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Estadísticas")
                }
        }
        .accentColor(Color.blue) // Color personalizado para resaltar pestañas activas
        .onAppear {
            UINavigationBar.appearance().isHidden = true
        }
        .onDisappear {
            UINavigationBar.appearance().isHidden = false
        }
    }
}
