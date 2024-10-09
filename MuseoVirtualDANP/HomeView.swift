import SwiftUI

struct HomeView: View {
    
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        VStack {
            Text("Welcome to Home!")
                .font(.largeTitle)
                .padding(.bottom, 40)
            
            Button("Logout", action: logout)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    func logout() {
        guard let token = UserDefaults.standard.string(forKey: "token") else { return }
        print("logout")
        let url = URL(string: "https://museo.epis-dev.site/api/auth/logout/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Logout failed: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            if httpResponse.statusCode == 200 {
                // Borrar datos de UserDefaults
                UserDefaults.standard.removeObject(forKey: "token")
                UserDefaults.standard.removeObject(forKey: "email")
                UserDefaults.standard.removeObject(forKey: "username")
                
                DispatchQueue.main.async {
                    self.isLoggedIn = false
                }
            }
        }.resume()
    }
}
