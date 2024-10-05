//
//  CreatedAccountView.swift
//  MuseoVirtualDANP
//
//  Created by MacEpis on 5/10/24.
//

import SwiftUI

struct CreateAccountView: View {
    
    @State private var username = ""
    @State private var password = ""
    @State private var name = ""
    @State private var email = ""
    @Binding var users: [User]
    @Environment(\.presentationMode) var presentationMode // Para volver a la pantalla anterior
    
    var body: some View {
        VStack {
            Text("Create Account")
                .font(.largeTitle)
                .padding(.bottom, 40)
            
            TextField("Name", text: $name)
                .padding()
                .textFieldStyle(.roundedBorder)
            
            TextField("Email", text: $email)
                .padding()
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            TextField("Username", text: $username)
                .padding()
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(.roundedBorder)
            
            Button("Create Account", action: createAccount)
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)
        }
        .padding()
    }
    
    func createAccount() {
        let newUser = User(username: username, password: password, name: name, email: email)
        users.append(newUser)
        print("Cuenta creada para \(username)")
        
        // Volver automáticamente al login después de crear la cuenta
        presentationMode.wrappedValue.dismiss()
    }
}
