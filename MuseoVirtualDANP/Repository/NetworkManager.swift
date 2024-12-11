import Foundation

class URLSessionPinningDelegate: NSObject, URLSessionDelegate {
    private let pinnedCertificateData: Data
    
    init(certificateName: String, certificateExtension: String = "der") {
        // Cargar el certificado anclado desde el bundle
        guard let path = Bundle.main.path(forResource: certificateName, ofType: certificateExtension),
              let certificateData = NSData(contentsOfFile: path) as Data? else {
            fatalError("Failed to load pinned certificate: \(certificateName).\(certificateExtension)")
        }
        self.pinnedCertificateData = certificateData
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        
        var secResult = SecTrustResultType.invalid
        let status = SecTrustEvaluate(serverTrust, &secResult)
        
        if status == errSecSuccess {
            guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }
            
            let remoteCertificateData = SecCertificateCopyData(certificate) as Data
            
            if remoteCertificateData == pinnedCertificateData {
                print("Certificate validated successfully")
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            } else {
                print("Certificate validation failed")
            }
        }
        
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}

struct URLSessionFactory {
    static func createSession(withCertificateName certificateName: String) -> URLSession {
        let delegate = URLSessionPinningDelegate(certificateName: certificateName)
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: delegate, delegateQueue: nil)
    }
}
