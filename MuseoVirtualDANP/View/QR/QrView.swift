//
//  QrView.swift
//  MuseoVirtualDANP
//
//  Created by MacEpis on 5/11/24.
//
import SwiftUI
import AVFoundation
import Vision

// 1. Application main interface
struct QrView: View {

    @State private var scannedString: String = "Scan a QR code or barcode"
    
    var body: some View {
    
        ZStack(alignment: .bottom) {
            ScannerView(scannedString: $scannedString)
                .edgesIgnoringSafeArea(.all)
                
            Text(scannedString)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
        }
    }
}

struct ScannerView: UIViewControllerRepresentable {

    @Binding var scannedString: String
    
    let captureSession = AVCaptureSession()
    
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else { return viewController }
        
        captureSession.addInput(videoInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        
        if captureSession.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue"))
            captureSession.addOutput(videoOutput)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
            var parent: ScannerView
            private var requests = [VNRequest]()
            
            init(_ parent: ScannerView) {
                self.parent = parent
                super.init()
                setupVision()
            }
            
            private func setupVision() {
                let barcodeRequest = VNDetectBarcodesRequest(completionHandler: self.handleBarcodes)
                
                // Specify the symbologies you want to detect
                barcodeRequest.symbologies = [.qr, .ean8, .code39, .aztec]
                
                self.requests = [barcodeRequest]
            }
            
            func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
                guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
                
                let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
                do {
                    try imageRequestHandler.perform(self.requests)
                } catch {
                    print("Failed to perform barcode detection: \\(error)")
                }
            }
            
            private func handleBarcodes(request: VNRequest, error: Error?) {
                if let error = error {
                    print("Barcode detection error: \\(error)")
                    return
                }
                
                guard let results = request.results as? [VNBarcodeObservation] else { return }
                for barcode in results {
                    if let payload = barcode.payloadStringValue {
                        Task {
                            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                            self.parent.scannedString = payload
                        }
                        // Optionally, stop scanning after first detection
                        // self.parent.captureSession?.stopRunning()
                    }
                }
            }
        }}
