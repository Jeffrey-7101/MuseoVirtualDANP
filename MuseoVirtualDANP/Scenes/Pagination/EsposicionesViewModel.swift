//
//  EsposicionesViewModel.swift
//  MuseoVirtualDANP
//
//  Created by MacEpis on 22/10/24.
//

import Foundation
import Combine

class ExposicionesViewModel: ObservableObject {
    @Published var exposiciones: [ExposicionDate] = []
    @Published var isLoading = false
    private var currentPage = 1
    private var canLoadMorePages = true
    private var cancellables = Set<AnyCancellable>()
    
    func loadMoreExposiciones(){
        guard !isLoading, canLoadMorePages else { return }
        isLoading = true
        
        let urlString = "https://museo.epis-dev.site/api/museo/exposiciones/?page=\(currentPage)&page_size=2"
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: APIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in self?.isLoading = false
                if case.failure(let error) = completion {
                    print("Error fetching Exposiones: \(error)")
                }  
            }, receiveValue: { [weak self] response in
                self?.exposiciones.append(contentsOf: response.results)
                self?.currentPage += 1
                self?.canLoadMorePages = response.next != nil
            })
            .store(in: &cancellables)
    }
}
