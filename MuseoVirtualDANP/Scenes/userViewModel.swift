//
//  userViewModel.swift
//  MuseoVirtualDANP
//
//  Created by epismac on 16/10/24.
//

import Foundation
import Combine
import SwiftUI

class UserViewModel: ObservableObject {
    @Published var users: [UserData] = []
    
    func fetchUsers() {
        
        guard let url = URL(string: "https://museo.epis-dev.site/api/museo/salas/") else { return }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request){ data, response, error in if let error = error {
                print("Error fetching data \(error)")
                return
            }
            
            guard let data = data else { return }
            
            
            
        }
    }
}
