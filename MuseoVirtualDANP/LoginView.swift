//
//  LoginView.swift
//  MuseoVirtualDANP
//
//  Created by MacEpis on 5/10/24.
//

import SwiftUI


struct LoginView: View {
    
    @State private var username = ""
    @State private var password = ""
    @Binding var isLoggedIn: Bool
    @Binding var users: [User]
    
    var body: some View {
        VStack {
            Text("Login")
                .font(.largeTitle)
                .padding(.bottom, 40)
            
            TextField("Username", text: $username)
                .padding()
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(.roundedBorder)
            
            Button("Login", action: login)
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)
            
            NavigationLink(destination: CreateAccountView(users: $users)) {
                Text("Create Account")
                    .padding(.top, 10)
            }
        }
        .padding()
    }
    
    func login() {
        if let _ = users.first(where: { $0.username == username && $0.password == password }) {
            isLoggedIn = true
        } else {
            print("Usuario o contraseña incorrectos")
        }
    }
}
