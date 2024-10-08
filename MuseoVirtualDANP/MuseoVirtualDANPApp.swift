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
            let persistenceController = PersistenceController.shared
            NavigationView {
                if isLoggedIn {
                    TabNavigatioView(isloggedIn: $isLoggedIn)
                } else {
                    LoginView(isLoggedIn: $isLoggedIn)
                }
            }.environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
