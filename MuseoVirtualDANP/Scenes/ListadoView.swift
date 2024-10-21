//
//  ListView.swift
//  MuseoVirtualDANP
//
//  Created by MacEpis on 16/10/24.
//

import Combine
import SwiftUI
import Foundation

// Modelo para un usuario


class ApiService {
    func fetchUsers(page: Int, completion: @escaping (Result<[User], Error>) -> Void) {
        let urlString = "https://randomuser.me/api/?page=\(page)&results=5"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else { return }
            
            do {
                let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(userResponse.results))
                }
                print("Page: \(userResponse.info.page), Users fetched: \(userResponse.results.count)")
            } catch let decodingError {
                DispatchQueue.main.async {
                    completion(.failure(decodingError))
                }
            }
        }.resume()
    }
}

class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    private var page = 1
    
    private let apiService = ApiService()
    
    func fetchMoreUsers(currentUser: User?) {
        guard !isLoading else { return }
        
        // Si estamos cerca del final de la lista, cargamos más usuarios
        if let currentUser = currentUser {
            let thresholdIndex = users.index(users.endIndex, offsetBy: -3)
            if users.firstIndex(where: { $0.id == currentUser.id }) == thresholdIndex {
                loadUsers()
            }
        }
    }
    
    func loadUsers() {
        isLoading = true
        apiService.fetchUsers(page: page) { result in
            switch result {
            case .success(let newUsers):
                self.users.append(contentsOf: newUsers)
                self.page += 1
            case .failure(let error):
                print("Error fetching users: \(error.localizedDescription)")
            }
            self.isLoading = false
        }
    }
}


struct ListadoView: View {
    @StateObject private var viewModel = UserViewModel()
    
    var body: some View {
        VStack{
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.users) { user in
                        HStack {
                            AsyncImage(url: URL(string: user.picture.thumbnail)) { image in
                                image.resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .padding()
                            
                            VStack(alignment: .leading) {
                                Text("\(user.name.title) \(user.name.first) \(user.name.last)")
                                    .font(.headline)
                                Text(user.email)
                                    .font(.subheadline)
                            }
                            Spacer()
                        }
                        .onAppear {
                            viewModel.fetchMoreUsers(currentUser: user)
                        }
                    }
                    
                    if viewModel.isLoading {
                        ProgressView("Cargando más...")
                            .padding()
                    }
                }
            }
        }
        .navigationTitle("Usuarios")
        .onAppear {
            if viewModel.users.isEmpty {
                viewModel.loadUsers()
            }
        }
    }
}

