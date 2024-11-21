import SwiftUI
import Foundation
import Combine
class URLSessionPinningDelegate: NSObject, URLSessionDelegate {
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        // Verificar que el objeto serverTrust exista
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

class FoodListViewModel: ObservableObject {
    @Published var alimentos: [FoodData] = []
    @Published var isLoading = false
    private var currentPage = 1
    private var canLoadMorePages = true
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var session: URLSession = {
        if false { // for debug
            let configuration = URLSessionConfiguration.default
            return URLSession(configuration: configuration, delegate: URLSessionPinningDelegate(), delegateQueue: nil)
        } else {
            return URLSession.shared
        }
    }()
    
    func loadMoreFoods() {
        guard !isLoading, canLoadMorePages else { return }
        isLoading = true
        
        let urlString = "https://museo.epis-dev.site/api/alimentos/?page=\(currentPage)&page_size=6"
        guard let url = URL(string: urlString) else { return }
        
        print("Loading new page of foods")
        
        session.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: APIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print("Error fetching Foods: \(error)")
                }
            }, receiveValue: { [weak self] response in
                self?.alimentos.append(contentsOf: response.results)
                self?.currentPage += 1
                self?.canLoadMorePages = response.next != nil
            })
            .store(in: &cancellables)
    }
}

struct FoodListView: View {
    @StateObject private var viewModel = FoodListViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.alimentos) { alimento in
                        NavigationLink(destination: FoodDetailView(alimento: alimento)) {
                            FoodRow(alimento: alimento)
                                .onAppear {
                                    if alimento.codigo == viewModel.alimentos.last?.codigo {
                                        viewModel.loadMoreFoods()
                                    }
                                }
                        }
                    }
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Foods")
            .onAppear {
                if viewModel.alimentos.isEmpty {
                    viewModel.loadMoreFoods()
                }
            }
        }
    }
}

struct FoodRow: View {
    let alimento: FoodData
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(alimento.nombre)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Category: \(alimento.categoria)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Protein: \(alimento.proteina, specifier: "%.1f")g")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Fat: \(alimento.grasa, specifier: "%.1f")g")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Text("Energy: \(alimento.energia, specifier: "%.1f") kcal")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 4)
    }
}

struct FoodDetailView: View {
    let alimento: FoodData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(alimento.nombre)
                    .font(.largeTitle)
                    .bold()
                
                Text("Category: \(alimento.categoria)")
                    .font(.headline)
                
                Text("Protein: \(alimento.proteina, specifier: "%.1f")g")
                    .font(.subheadline)
                
                Text("Fat: \(alimento.grasa, specifier: "%.1f")g")
                    .font(.subheadline)
                
                Text("Carbohydrates: \(alimento.carbohidrato, specifier: "%.1f")g")
                    .font(.subheadline)
                
                Text("Energy: \(alimento.energia, specifier: "%.1f") kcal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .navigationTitle(alimento.nombre)
    }
}

struct FoodData: Identifiable, Codable {
    let id = UUID() // Not part of the API; for SwiftUI ForEach compatibility
    let codigo: Int
    let nombre: String
    let categoria: String
    let proteina: Float
    let grasa: Float
    let carbohidrato: Float
    let energia: Float
}

struct APIResponse: Codable {
    let next: String?
    let results: [FoodData]
}
