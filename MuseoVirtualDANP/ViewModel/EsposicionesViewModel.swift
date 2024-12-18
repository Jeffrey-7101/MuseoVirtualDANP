import Foundation
import Combine

class ExposicionesViewModel: ObservableObject {
    @Published var exposiciones: [Exposicion] = []
    @Published var isLoading = false
    private var currentPage = 1
    private var canLoadMorePages = true
    private var cancellables = Set<AnyCancellable>()
    
    private let repository: ExposicionesRepository
    
    init(repository: ExposicionesRepository = ExposicionesRepository(session: URLSession.shared)) {
        self.repository = repository
    }
    
    func loadMoreExposiciones() {
        guard !isLoading, canLoadMorePages else { return }
        isLoading = true
        
        repository.fetchExposiciones(page: currentPage, pageSize: 6)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error fetching Exposiciones: \(error)")
                }
            }, receiveValue: { [weak self] response in
                self?.exposiciones.append(contentsOf: response.results)
                self?.currentPage += 1
                self?.canLoadMorePages = response.next != nil
            })
            .store(in: &cancellables)
    }
}
