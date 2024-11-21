

import Foundation
import Combine


class FoodListViewModel: ObservableObject {
    @Published var exposiciones: [FoodData] = []
    @Published var isLoading = false
    private var currentPage = 1
    private var canLoadMorePages = true
    private var cancellables = Set<AnyCancellable>()
    
    // URLSession personalizada con el delegado para pinning
    private lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: URLSessionPinningDelegate(), delegateQueue: nil)
    }()
    
    func loadMoreExposiciones(){
        guard !isLoading, canLoadMorePages else { return }
        isLoading = true
        
        let urlString = "https://museo.epis-dev.site/api/museo/exposiciones/?page=\(currentPage)&page_size=6"
        guard let url = URL(string: urlString) else { return }
        
        print("load new page")
        
        session.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: APIResponse.self, decoder: JSONDecoder())
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

class URLSessionPinningDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // Verificar que el objeto `serverTrust` exista
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Evaluar la confianza en el servidor
        var secResult = SecTrustResultType.invalid
        let status = SecTrustEvaluate(serverTrust, &secResult)
        
        if status == errSecSuccess {
            // Extraer el certificado del servidor
            guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }

            // Cargar el certificado anclado
            guard let pathToPinnedCertificate = Bundle.main.path(forResource: "museo", ofType: "der"),
                  let pinnedCertificateData = NSData(contentsOfFile: pathToPinnedCertificate) else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            
            // Convertir el certificado del servidor a formato Data
            let remoteCertificateData = SecCertificateCopyData(certificate) as Data

            // Comparar el certificado anclado con el del servidor
            if pinnedCertificateData as Data == remoteCertificateData {
                // Si coinciden, proceder con la conexión
                print("certificado valido")
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            }
        }

        // Si no coinciden, cancelar la conexión
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
