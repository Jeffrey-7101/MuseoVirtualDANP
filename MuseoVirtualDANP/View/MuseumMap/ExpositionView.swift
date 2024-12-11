import Foundation
import SwiftUI

//struct Exposition {
//    let id: UUID
//    let name: String
//    let shape: ShapeType
//    let bgColor: String
//    let borderColor: String
//    let drawBorder: Bool
//    let relativeFrame: CGRect
//    enum ShapeType {
//        case rectangle
//    }
//}
//
//struct ExpositionView: View {
//    let exposition: Exposition
//    let roomOrigin: CGPoint
//    let scale: CGFloat
//    let bgColor: String
//    let onTap: () -> Void
//
//    var body: some View {
//        Rectangle()
//            .fill(Color(hex: bgColor))
//            .frame(width: exposition.relativeFrame.width * scale, height: exposition.relativeFrame.height * scale)
//            .position(x: (roomOrigin.x + exposition.relativeFrame.midX) * scale, y: (roomOrigin.y + exposition.relativeFrame.midY) * scale)
//            .onTapGesture {
//                onTap()
//            }
//    }
//}
