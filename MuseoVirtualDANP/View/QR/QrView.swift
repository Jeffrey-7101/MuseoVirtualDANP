import SwiftUI
import AVFoundation
import Vision

// 1. Application main interface
struct QrView: View {

    @State private var scannedString: String = "Scan a QR code or barcode"
    
    
    @State private var isLinkActive:Bool = false
    @State private var selectedExposition:Int? = nil
    
//    Exposicion(id: 0, titulo: "", tecnica: "", categoria: "", descripcion: "", ano: 0, imagen: "", audio: "", posX: 0, posY: 0, width: 0, height: 0, bg_color: "", border_color: "", border: false)
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScannerView(scannedString: $scannedString, isLinkActive: $isLinkActive, selectedExposition: $selectedExposition)
                .edgesIgnoringSafeArea(.all)
                
            Text(scannedString)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
        }.background(
                NavigationLink(destination: ExposicionDetalleView(exposicionId: selectedExposition), isActive: $isLinkActive) {
                    EmptyView()
                }
                .hidden()
        ).onAppear{
            isLinkActive = false
            selectedExposition = nil
        }
    }
}

struct ScannerView: UIViewControllerRepresentable {
    @Binding var scannedString: String
    @Binding var isLinkActive: Bool
    @Binding var selectedExposition: Int?
    
    let captureSession = AVCaptureSession()
    
    // Añadimos esta función que se pasará al Coordinator
    func updateValues(text: String, isActive: Bool, exposition: Int?) {
        scannedString = text
        isLinkActive = isActive
        selectedExposition = exposition
    }
    
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        checkCameraAuthorization(for: viewController)
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, updateValues: updateValues)
    }
    
    // Función para verificar permisos de cámara
    func checkCameraAuthorization(for viewController: UIViewController) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startSession(for: viewController)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        startSession(for: viewController)
                    }
                } else {
                    print("Permiso de cámara denegado por el usuario")
                }
            }
        case .denied, .restricted:
            print("Permiso de cámara denegado o restringido")
        @unknown default:
            break
        }
    }
    
    // Función para iniciar la sesión de captura
    func startSession(for viewController: UIViewController) {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            return
        }
        
        captureSession.addInput(videoInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        
        if captureSession.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(makeCoordinator(), queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(videoOutput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: ScannerView
        private var requests = [VNRequest]()
        private var updateValues: (String, Bool, Int?) -> Void
        
        init(_ parent: ScannerView, updateValues: @escaping (String, Bool, Int?) -> Void) {
            self.parent = parent
            self.updateValues = updateValues
            super.init()
            setupVision()
        }
        
        private func setupVision() {
            let barcodeRequest = VNDetectBarcodesRequest(completionHandler: self.handleBarcodes)
            barcodeRequest.symbologies = [.qr, .ean8, .code39, .aztec]
            self.requests = [barcodeRequest]
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
            do {
                try imageRequestHandler.perform(self.requests)
            } catch {
                print("Failed to perform barcode detection: \(error)")
            }
        }
        
        private func handleBarcodes(request: VNRequest, error: Error?) {
                if let error = error {
                    print("Barcode detection error: \(error)")
                    return
                }
                
                guard let results = request.results as? [VNBarcodeObservation] else { return }
                for barcode in results {
                    if let payload = barcode.payloadStringValue {
                        Task { @MainActor in
                            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                            
                            if let numero = Int(payload) {
                                print("valido. intentando ir al detalle")
                                updateValues(payload, true, numero)
                            } else {
                                print("Numero invalido")
                                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                                updateValues("El QR no es un id valido", false, nil)
                            }
                        }
                    }
                }
            }
    }
}
