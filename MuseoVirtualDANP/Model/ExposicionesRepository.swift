import Foundation
import Combine

protocol ExposicionesRepositoryProtocol {
    func fetchExposiciones(page: Int) -> AnyPublisher<APIResponse, Error>
}

class ExposicionesRepository {
    private let session: URLSession
    private let baseURL = "https://museo.epis-dev.site/api/museo/exposiciones/"
    
    init(session: URLSession = URLSessionFactory.createSession(withCertificateName: "museo")) {
        self.session = session
    }
    
    func fetchExposiciones(page: Int, pageSize: Int) -> AnyPublisher<APIResponse, Error> {
        guard let url = URL(string: "\(baseURL)?page=\(page)&page_size=\(pageSize)") else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        return session.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: APIResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
