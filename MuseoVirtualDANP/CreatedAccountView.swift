//
//  CreatedAccountView.swift
//  MuseoVirtualDANP
//
//  Created by MacEpis on 5/10/24.
//

import SwiftUI

struct CreateAccountView: View {
    
    @State private var username = ""
    @State private var password1 = ""
    @State private var password2 = ""
    @State private var email = ""
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Create Account")
                .font(.largeTitle)
                .padding(.bottom, 40)
            
            TextField("Email", text: $email)
                .padding()
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            TextField("Username", text: $username)
                .padding()
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password1)
                .padding()
                .textFieldStyle(.roundedBorder)
            
            SecureField("Confirm Password", text: $password2)
                .padding()
                .textFieldStyle(.roundedBorder)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
            
            Button("Create Account", action: createAccount)
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)
        }
        .padding()
    }
    
    func createAccount() {
        guard password1 == password2 else {
            errorMessage = "Passwords do not match"
            return
        }
        
        let url = URL(string: "https://museo.epis-dev.site/api/auth/register/")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["email": email, "username": username, "password1": password1, "password2": password2]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            if httpResponse.statusCode == 204 {
                DispatchQueue.main.async {
                    self.presentationMode.wrappedValue.dismiss()
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Registration failed. Please check your details."
                }
            }
        }.resume()
    }
}
