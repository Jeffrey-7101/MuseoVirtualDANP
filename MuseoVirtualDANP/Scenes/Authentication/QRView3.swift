import AVFoundation
import SwiftUI

class CameraViewController: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    private var session: AVCaptureSession
    @Published var scannedCode: String?

    override init() {
        self.session = AVCaptureSession()
        super.init()
        configureSession()
    }
    
    private func configureSession() {
        guard let videoDevice = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr] // Solo escanear códigos QR
            }
            
        } catch {
            print("Error configurando la sesión de captura: \(error)")
            return
        }
    }
    
    func startSession() {
        if !session.isRunning {
            session.startRunning()
        }
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }

    // Delegate para procesar los códigos escaneados
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject else { return }
        if metadataObject.type == .qr, let scannedText = metadataObject.stringValue {
            DispatchQueue.main.async {
                self.scannedCode = scannedText
                self.stopSession() // Detiene la sesión tras escanear un código
            }
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }
    
    func checkCameraAuthorization() {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                startSession()
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.startSession()
                    }
                }
            case .denied, .restricted:
                // Mostrar un mensaje o manejar la falta de permisos
                print("Permiso de cámara denegado o restringido")
            @unknown default:
                break
            }
        }
}

struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraController: CameraViewController

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let previewLayer = cameraController.getPreviewLayer()
        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Actualizar la vista si es necesario
    }
}


struct QRScannerView: View {
    @StateObject private var cameraController = CameraViewController()

    var body: some View {
        ZStack {
            CameraPreview(cameraController: cameraController)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    cameraController.checkCameraAuthorization()
                }
                .onDisappear {
                    cameraController.stopSession()
                }
            
            if let scannedCode = cameraController.scannedCode {
                Text("Código Escaneado: \(scannedCode)")
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
        }
    }
}
