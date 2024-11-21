

//            NavigationLink(destination: CreateAccountView()) {
//                Text("Create Account")
//                    .padding(.top, 10)
//            }

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false // Indica si la solicitud está en curso
    @Binding var isLoggedIn: Bool

    var body: some View {
        ZStack {
            // Fondo con gradiente temático
            LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.6), Color.blue.opacity(0.4)]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Título estilizado
                Text("🍎 Food Data")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                    .padding(.bottom, 50)

                // Campo de texto para el email
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)

                // Campo de texto para la contraseña
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
                    .shadow(radius: 3)

                // Mensaje de error (si lo hay)
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 5)
                }

                // Indicador de carga o botón de login
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.top, 20)
                } else {
                    Button(action: login) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.blue]),
                                                       startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                    .padding(.top, 20)
                    .scaleEffect(1.1)
                    .animation(.easeIn(duration: 0.2), value: isLoading)
                }
                
                NavigationLink(destination: CreateAccountView()) {
                    Text("Create Account")
                        .padding(.top, 10)
                }
                
                
            }
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
        }
    }

    func login() {
        guard !email.isEmpty && !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }

        isLoading = true
        errorMessage = nil

        performLoginRequest(email: email, password: password) { result in
            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .success(let (token, email, username)):
                    // Guardar en UserDefaults
                    UserDefaults.standard.set(token, forKey: "token")
                    UserDefaults.standard.set(email, forKey: "email")
                    UserDefaults.standard.set(username, forKey: "username")

                    self.isLoggedIn = true
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func performLoginRequest(email: String, password: String, completion: @escaping (Result<(String, String, String), Error>) -> Void) {
        guard let url = URL(string: "https://museo.epis-dev.site/api/auth/login/") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL."])))
            return
        }

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

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid server response."])))
                return
            }

            if httpResponse.statusCode == 200 {
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let token = json["key"] as? String,
                      let email = json["email"] as? String,
                      let username = json["username"] as? String else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid data format."])))
                    return
                }

                completion(.success((token, email, username)))
            } else {
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
                completion(.failure(NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
            }
        }.resume()
    }
}
