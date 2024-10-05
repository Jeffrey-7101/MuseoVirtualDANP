//
//  MuseoVirtualDANPApp.swift
//  MuseoVirtualDANP
//
//  Created by epismac on 3/10/24.
//
import SwiftUI

@main
struct LoginApp: App {
    
    @State var isLoggedIn: Bool = UserDefaults.standard.string(forKey: "token") != nil
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if isLoggedIn {
                    HomeView(isLoggedIn: $isLoggedIn)
                        .navigationBarBackButtonHidden(true)
                } else {
                    LoginView(isLoggedIn: $isLoggedIn)
                }
            }
        }
    }
}
