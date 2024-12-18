import Foundation
import Combine

class ExposicionDetalleViewModel: ObservableObject {
    @Published var exposicion: Exposicion?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellable: AnyCancellable?
    private let repository = ExposicionesRepository()
    
    func fetchExposicion(by id: Int) {
        isLoading = true
        cancellable = repository.fetchExposicion(by: id)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case let .failure(error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("Error fetching exposicion: \(error)")
                }
            }, receiveValue: { [weak self] exposicion in
                self?.exposicion = exposicion
            })
    }
}
