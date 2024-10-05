import SwiftUI

// MARK: - Modelo de Sala del Museo
struct MuseumRoom {
    let id: UUID
    let name: String
    let frame: CGRect
    var expositions: [Exposition]
    
    init(name: String, frame: CGRect, expositions: [Exposition]) {
        self.id = UUID()
        self.name = name
        self.frame = frame
        self.expositions = expositions
    }
}

// MARK: - Modelo de Exposición (Pintura)
struct Exposition {
    let id: UUID
    let name: String
    let shape: ShapeType
    let relativeFrame: CGRect
    
    enum ShapeType {
        case circle
        case rectangle
    }
    
    init(name: String, shape: ShapeType, relativeFrame: CGRect) {
        self.id = UUID()
        self.name = name
        self.shape = shape
        self.relativeFrame = relativeFrame
    }
}

// MARK: - Vista para una Exposición (Pintura)
struct ExpositionView: View {
    let exposition: Exposition
    let roomOrigin: CGPoint
    let scale: CGFloat
    let onTap: () -> Void

    var body: some View {
        ZStack {
            if exposition.shape == .circle {
                Circle()
                    .fill(Color.orange)
                    .frame(width: exposition.relativeFrame.width * scale, height: exposition.relativeFrame.height * scale)
            } else {
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: exposition.relativeFrame.width * scale, height: exposition.relativeFrame.height * scale)
            }
        }
        .position(x: (roomOrigin.x + exposition.relativeFrame.midX) * scale, y: (roomOrigin.y + exposition.relativeFrame.midY) * scale)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Vista para una Sala del Museo
struct RoomView: View {
    let room: MuseumRoom
    let scale: CGFloat
    let isSelected: Bool
    let maxScale: CGFloat
    let adjustedOrigin: CGPoint
    let onTapRoom: () -> Void
    let onTapExposition: (Exposition) -> Void

    var body: some View {
        ZStack {
            // Sala
            Rectangle()
                .strokeBorder(Color.black, lineWidth: 3 * scale)
                .background(Rectangle().fill(Color.gray.opacity(0.9)))
                .frame(width: room.frame.width * scale, height: room.frame.height * scale)
                .position(x: (adjustedOrigin.x + room.frame.width / 2) * scale, y: (adjustedOrigin.y + room.frame.height / 2) * scale)
                .onTapGesture {
                    onTapRoom()
                }
                .animation(.easeInOut) // Aplicamos la animación a la sala
            
            // Nombre de la sala (texto no escalado)
            Text(room.name)
                .font(.caption)
                .bold()
                .foregroundColor(.black)
                .position(x: (adjustedOrigin.x + room.frame.width / 2) * scale, y: (adjustedOrigin.y - 10) * scale)

            // Exposiciones dentro de la sala
            ForEach(room.expositions, id: \.id) { exposition in
                ExpositionView(exposition: exposition, roomOrigin: adjustedOrigin, scale: scale) {
                    onTapExposition(exposition)
                }
            }
        }
    }
}

// MARK: - Vista del Mapa del Museo
struct MuseumMapView: View {
    let rooms: [MuseumRoom]
    let targetSize: CGSize // Tamaño deseado del museo
    
    @State private var selectedRoom: UUID? // Rastrea la sala seleccionada
    
    var body: some View {
        let originalSize = CGSize(width: 400, height: 600) // Tamaño base del museo
        let scale = min(targetSize.width / originalSize.width, targetSize.height / originalSize.height) // Factor de escala

        // Ordenar las salas: si hay una sala seleccionada, esta se dibuja al final
        let sortedRooms = rooms.sorted { room1, room2 in
            if let selectedRoom = selectedRoom {
                return room1.id == selectedRoom ? false : true
            }
            return true
        }

        ZStack {
            ForEach(sortedRooms, id: \.id) { room in
                let isSelected = selectedRoom == room.id
                let maxScale = min(targetSize.width / room.frame.width, targetSize.height / room.frame.height) // Escala máxima que puede ocupar la sala
                
                // Si está seleccionada, su origen se ajusta al (0, 0) para centrarla
                let adjustedOrigin = isSelected ? CGPoint(x: 0, y: 0) : room.frame.origin
                
                RoomView(
                    room: room,
                    scale: isSelected ? maxScale : scale, // Si está seleccionada, usar la escala máxima
                    isSelected: isSelected,
                    maxScale: maxScale,
                    adjustedOrigin: adjustedOrigin, // Cambia la posición de la sala
                    onTapRoom: {
                        withAnimation(.easeInOut) { // Añadimos una animación suave
                            if selectedRoom == room.id {
                                selectedRoom = nil // Deseleccionar si ya estaba seleccionada
                            } else {
                                selectedRoom = room.id // Seleccionar la sala
                            }
                        }
                    },
                    onTapExposition: { exposition in
                        print("Exposición seleccionada: \(exposition.name)")
                    }
                )
            }
        }
        .frame(width: targetSize.width, height: targetSize.height)
        .background(Color.white)
    }
}
