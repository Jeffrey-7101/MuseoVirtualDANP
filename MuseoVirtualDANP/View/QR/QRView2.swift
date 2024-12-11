//
//  QRView2.swift
//  MuseoVirtualDANP
//
//  Created by MacEpis on 5/11/24.
//

import SwiftUI
import Vision

struct QRView2: View {
    
    @State var qrData = ""
    
    let qrImage = UIImage(named: "qrcode")
    
    var body: some View {
        VStack {
            Image(uiImage: qrImage!)
                .resizable()
                .scaledToFit()
            
            Button("Extract QR Data"){
                qrData =   extractQRCode(image: qrImage!)!
            }
            Text(qrData)
        }
        .padding()
        
    }
    
    private func extractQRCode(image: UIImage) -> String? {
        let qrImage = image
        let cgImage = qrImage.cgImage
        
        // Request handler
        let handler = VNImageRequestHandler(cgImage: cgImage!)
        
        let barcodeRequest = VNDetectBarcodesRequest()
        barcodeRequest.symbologies = [.qr]
        
        // Process the request
        try?handler.perform([barcodeRequest])
        
        // Get data from QR
        guard let results = barcodeRequest.results, let firstBarcode = results.first?.payloadStringValue else {
            return nil
        }
        print(firstBarcode)
        return firstBarcode
    }
}
