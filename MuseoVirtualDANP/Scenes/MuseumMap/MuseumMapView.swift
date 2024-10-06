import SwiftUI

// Modelo de Sala del Museo
struct MuseumRoom {
    let id: Int
    let name: String
    let description: String
    let frame: CGRect
    var expositions: [Exposition]
}

// Modelo de Exposición
struct Exposition {
    let id: Int
    let name: String
    let description: String
    let relativeFrame: CGRect
    let imageURL: URL?
}

// Vista para una Exposición (siempre rectángulo)
struct ExpositionView: View {
    let exposition: Exposition
    let roomOrigin: CGPoint
    let scale: CGFloat
    let onTap: () -> Void

    var body: some View {
        Rectangle()
            .fill(Color.blue)
            .frame(width: exposition.relativeFrame.width * scale, height: exposition.relativeFrame.height * scale)
            .position(x: (roomOrigin.x + exposition.relativeFrame.midX) * scale, y: (roomOrigin.y + exposition.relativeFrame.midY) * scale)
            .onTapGesture {
                onTap()
            }
    }
}

// Clase para gestionar los datos
class MuseumData: ObservableObject {
    @Published var rooms: [MuseumRoom] = []

    func fetchRooms() {
        guard let url = URL(string: "https://museo.epis-dev.site/api/museo/salas/") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching rooms: \(error)")
                return
            }

            guard let data = data else { return }

            do {
                // Parseamos los datos de la API
                if let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                    DispatchQueue.main.async {
                        self.rooms = jsonArray.compactMap { roomJSON in
                            guard let id = roomJSON["id"] as? Int,
                                  let name = roomJSON["nombre"] as? String,
                                  let description = roomJSON["descripcion"] as? String,
                                  let posX = roomJSON["posX"] as? Double,
                                  let posY = roomJSON["posY"] as? Double,
                                  let width = roomJSON["width"] as? Double,
                                  let height = roomJSON["height"] as? Double else {
                                return nil // Si falta algún dato esencial, omitimos la sala
                            }

                            // Mapear las exposiciones
                            let expositions: [Exposition] = (roomJSON["exposiciones"] as? [[String: Any]])?.compactMap { expoJSON in
                                guard let expoId = expoJSON["id"] as? Int,
                                      let title = expoJSON["titulo"] as? String,
                                      let expoPosX = expoJSON["posX"] as? Double,
                                      let expoPosY = expoJSON["posY"] as? Double,
                                      let expoWidth = expoJSON["width"] as? Double,
                                      let expoHeight = expoJSON["height"] as? Double,
                                      let imageURLString = expoJSON["imagen"] as? String else {
                                    return nil // Omitir si los datos de la exposición no están completos
                                }

                                let imageURL = URL(string: imageURLString)

                                return Exposition(
                                    id: expoId,
                                    name: title,
                                    description: expoJSON["descripcion"] as? String ?? "",
                                    relativeFrame: CGRect(x: expoPosX, y: expoPosY, width: expoWidth, height: expoHeight),
                                    imageURL: imageURL
                                )
                            } ?? []

                            return MuseumRoom(
                                id: id,
                                name: name,
                                description: description,
                                frame: CGRect(x: posX, y: posY, width: width, height: height),
                                expositions: expositions
                            )
                        }
                    }
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }.resume()
    }
}


// Vista para una Sala del Museo
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
                .strokeBorder(Color.black, lineWidth: 3)
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
                .position(x: (adjustedOrigin.x + room.frame.width / 2) * scale, y: (adjustedOrigin.y + room.frame.height / 2) * scale)

            // Exposiciones dentro de la sala
            ForEach(room.expositions, id: \.id) { exposition in
                ExpositionView(exposition: exposition, roomOrigin: adjustedOrigin, scale: scale) {
                    onTapExposition(exposition)
                }
            }
        }.border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/, width: 2)
    }
}


// Vista del Mapa del Museo
struct MuseumMapView: View {
    @ObservedObject var museumData = MuseumData()
    let targetSize: CGSize // Tamaño deseado del museo
    
    @State private var selectedRoom: Int? // Rastrea la sala seleccionada

    var body: some View {
        let originalSize = CGSize(width: 11, height: 23) // Tamaño base del museo
        let scale = min(targetSize.width / originalSize.width, targetSize.height / originalSize.height) // Factor de escala

        // Ordenar las salas: si hay una sala seleccionada, esta se dibuja al final
        let sortedRooms = museumData.rooms.sorted { room1, room2 in
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
        .onAppear {
            museumData.fetchRooms() // Obtener los datos cuando la vista aparezca
        }
        .border(Color.black, width: 2)
    }
}

