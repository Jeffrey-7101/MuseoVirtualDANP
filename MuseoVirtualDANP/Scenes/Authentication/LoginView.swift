
import SwiftUI

//struct LoginView: View {
//    
//    @State private var email = ""
//    @State private var password = ""
//    @State private var errorMessage: String?
//    @Binding var isLoggedIn: Bool
//    
//    var body: some View {
//        VStack {
//            Text("Login")
//                .font(.largeTitle)
//                .padding(.bottom, 40)
//            
//            TextField("Email", text: $email)
//                .padding()
//                .textFieldStyle(.roundedBorder)
//                .autocapitalization(.none)
//                .keyboardType(.emailAddress)
//            
//            SecureField("Password", text: $password)
//                .padding()
//                .textFieldStyle(.roundedBorder)
//            
//            if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .padding(.top, 10)
//            }
//            
//            Button("Login", action: login)
//                .buttonStyle(.borderedProminent)
//                .padding(.top, 20)
//            
//            NavigationLink(destination: CreateAccountView()) {
//                Text("Create Account")
//                    .padding(.top, 10)
//            }
//        }
//        .padding()
//    }
//    
//    func login() {
//        let url = URL(string: "https://museo.epis-dev.site/api/auth/login/")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let body: [String: Any] = ["email": email, "password": password]
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                DispatchQueue.main.async {
//                    self.errorMessage = error.localizedDescription
//                }
//                return
//            }
//            
//            guard let httpResponse = response as? HTTPURLResponse else { return }
//            
//            if httpResponse.statusCode == 200 {
//                guard let data = data,
//                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                      let token = json["key"] as? String,
//                      let email = json["email"] as? String,
//                      let username = json["username"] as? String else { return }
//                
//                // Guardar en UserDefaults
//                UserDefaults.standard.set(token, forKey: "token")
//                UserDefaults.standard.set(email, forKey: "email")
//                UserDefaults.standard.set(username, forKey: "username")
//                
//                DispatchQueue.main.async {
//                    self.isLoggedIn = true
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self.errorMessage = "Login failed. Please check your credentials."
//                }
//            }
//        }.resume()
//    }
//}

struct LoginView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)
                .padding(.bottom, 40)
            
            TextField("Email", text: $email)
                .padding()
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(.roundedBorder)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
            
            Button("Login", action: login)
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)
            
            NavigationLink(destination: CreateAccountView()) {
                Text("Create Account")
                    .padding(.top, 10)
            }
        }
        .padding()
    }
    
    // Función de login que usa el closure escapable
    func login() {
        performLoginRequest(email: email, password: password) { result in
            switch result {
            case .success(let (token, email, username)):
                // Guardar en UserDefaults
                UserDefaults.standard.set(token, forKey: "token")
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(username, forKey: "username")
                
                DispatchQueue.main.async {
                    self.isLoggedIn = true
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // Nueva función que realiza la solicitud de red y acepta un closure escapable
    func performLoginRequest(email: String, password: String, completion: @escaping (Result<(String, String, String), Error>) -> Void) {
        let url = URL(string: "https://museo.epis-dev.site/api/auth/login/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            if httpResponse.statusCode == 200 {
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let token = json["key"] as? String,
                      let email = json["email"] as? String,
                      let username = json["username"] as? String else { return }
                
                completion(.success((token, email, username)))
            } else {
                let error = NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Login failed. Please check your credentials."])
                completion(.failure(error))
            }
        }.resume()
    }
}
