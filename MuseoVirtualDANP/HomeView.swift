//
//  HomeView.swift
//  MuseoVirtualDANP
//
//  Created by MacEpis on 5/10/24.
//

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
        isLoggedIn = false
    }
}
