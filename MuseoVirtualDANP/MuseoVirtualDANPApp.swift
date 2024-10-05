//
//  MuseoVirtualDANPApp.swift
//  MuseoVirtualDANP
//
//  Created by epismac on 3/10/24.
//
import SwiftUI
struct User {
    var username: String
    var password: String
    var name: String
    var email: String
}

@main
struct LoginApp: App {
    
    @State var users: [User] = [] // Almacenar los usuarios
    @State var isLoggedIn: Bool = false // Estado del login
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if isLoggedIn {
                    HomeView(isLoggedIn: $isLoggedIn)
                        .navigationBarBackButtonHidden(true) // No permitir volver al login
                } else {
                    LoginView(isLoggedIn: $isLoggedIn, users: $users)
                }
            }
        }
    }
}
