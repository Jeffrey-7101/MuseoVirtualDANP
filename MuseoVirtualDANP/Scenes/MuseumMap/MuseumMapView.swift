import SwiftUI
import CoreData

// Entidad de sala del museo
//@objc(MuseumRoomEntity)
//public class MuseumRoomEntity: NSManagedObject {
//    @NSManaged public var id: UUID?
//    @NSManaged public var name: String
//    @NSManaged public var posX: Double
//    @NSManaged public var posY: Double
//    @NSManaged public var width: Double
//    @NSManaged public var height: Double
//    @NSManaged public var expositions: NSSet?
//}
//
//// Entidad de exposición
//@objc(ExpositionEntity)
//public class ExpositionEntity: NSManagedObject {
//    @NSManaged public var id: UUID?
//    @NSManaged public var name: String
//    @NSManaged public var posX: Double
//    @NSManaged public var posY: Double
//    @NSManaged public var width: Double
//    @NSManaged public var height: Double
//    @NSManaged public var absolutePosition: Bool
//    @NSManaged public var room: MuseumRoomEntity?
//}
// MARK: - Estructura del Modelo
struct MuseumRoom {
    let id: UUID
    let name: String
    let frame: CGRect
    var expositions: [Exposition]
}

struct Exposition {
    let id: UUID
    let name: String
    let shape: ShapeType
    let relativeFrame: CGRect
    
    enum ShapeType {
        case rectangle
    }
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
                .animation(.easeInOut, value: isSelected)  // Aplicamos la animación a la sala
            
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
    @FetchRequest(
        entity: MuseumRoomEntity.entity(),
        sortDescriptors: []
    ) var rooms: FetchedResults<MuseumRoomEntity>
    
    let targetSize: CGSize
    @State private var selectedRoom: UUID?  // Estado para la sala seleccionada
    
    var body: some View {
        let originalSize = CGSize(width: 11, height: 23) // Tamaño base del museo
        let scale = min(targetSize.width / originalSize.width, targetSize.height / originalSize.height)
        
        // Ordenar salas: si una sala está seleccionada, se dibuja al final
        let sortedRooms = rooms.sorted { room1, room2 in
            if let selectedRoom = selectedRoom {
                return room1.id == selectedRoom ? false : true
            }
            return true
        }

        ZStack {
            ForEach(sortedRooms, id: \.id) { room in
                let expositions = (room.expositions?.allObjects as? [ExpositionEntity]) ?? []
                
                let museumRoom = MuseumRoom(
                    id: room.id!,
                    name: room.name ?? "va",
                    frame: CGRect(x: room.posX, y: room.posY, width: room.width, height: room.height),
                    expositions: expositions.map { exposition in
                        Exposition(
                            id: exposition.id!,
                            name: exposition.name ?? "vaa",
                            shape: .rectangle, // Por defecto todas las exposiciones serán rectángulos
                            relativeFrame: CGRect(x: exposition.posX, y: exposition.posY, width: exposition.width, height: exposition.height)
                        )
                    }
                )
                
                // Determinamos si la sala está seleccionada
                let isSelected = selectedRoom == room.id
                let maxScale = min(targetSize.width / museumRoom.frame.width, targetSize.height / museumRoom.frame.height)  // Escala máxima para la sala seleccionada
                
                // Si está seleccionada, se ajusta el origen para centrar la sala
                let adjustedOrigin = isSelected ? CGPoint(x: 0, y: 0) : museumRoom.frame.origin
                
                RoomView(
                    room: museumRoom,
                    scale: isSelected ? maxScale : scale,  // Si está seleccionada, usar escala máxima
                    isSelected: isSelected,
                    maxScale: maxScale,
                    adjustedOrigin: adjustedOrigin,
                    onTapRoom: {
                        withAnimation(.easeInOut) {  // Animación suave al hacer tap en la sala
                            if selectedRoom == room.id {
                                selectedRoom = nil  // Deseleccionar la sala si ya estaba seleccionada
                            } else {
                                selectedRoom = room.id  // Seleccionar la sala
                            }
                        }
                    },
                    onTapExposition: { _ in }
                )
            }
        }
        .frame(width: targetSize.width, height: targetSize.height)
        .onAppear {
            fetchMuseumData() // Llama a la API solo una vez al aparecer
        }
    }
}

// MARK: - Función para obtener datos del API
func fetchMuseumData() {
    guard let url = URL(string: "https://museo.epis-dev.site/api/museo/salas/") else { return }

    let request = URLRequest(url: url)
    
    print("super url")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Error al obtener datos: \(error)")
            return
        }
        
        guard let data = data else { return }
        
        // Decodificar JSON
        let decoder = JSONDecoder()
        do {
            let roomsData = try decoder.decode([MuseumRoomData].self, from: data)
            saveRoomsToCoreData(roomsData)
        } catch {
            print("Error al decodificar JSON: \(error)")
        }
    }.resume()
}

// MARK: - Función para guardar datos en Core Data
func saveRoomsToCoreData(_ roomsData: [MuseumRoomData]) {
    let context = PersistenceController.shared.container.viewContext
    
    for roomData in roomsData {
        let roomEntity = MuseumRoomEntity(context: context)
        roomEntity.id = roomData.id != nil ? UUID(uuidString: String(roomData.id!)) : UUID()
        roomEntity.name = roomData.nombre
        roomEntity.posX = roomData.posX
        roomEntity.posY = roomData.posY
        roomEntity.width = roomData.width
        roomEntity.height = roomData.height
        
        // Verifica si tiene UUID, sino asigna uno nuevo
        if roomEntity.id == nil {
            roomEntity.id = UUID()
        }
        
        print("saving")
        print(roomEntity)
        
        print("Museo")
        print(roomEntity)
//        print(roomsData)

        for expositionData in roomData.exposiciones {
            let expositionEntity = ExpositionEntity(context: context)
            expositionEntity.id = expositionData.id != nil ? UUID(uuidString: String(expositionData.id!)) : UUID()
            expositionEntity.name = expositionData.titulo
            expositionEntity.posX = expositionData.posX
            expositionEntity.posY = expositionData.posY
            expositionEntity.width = expositionData.width
            expositionEntity.height = expositionData.height
            if expositionEntity.id == nil {
                expositionEntity.id = UUID()
            }
            
            // Agregar la relación
            roomEntity.addToExpositions(expositionEntity)
            
//            print("otroooo")
//            print(expositionEntity)
        }
        
    }

    do {
        try context.save()
    } catch {
        print("Error al guardar en Core Data: \(error)")
    }
}

// MARK: - Modelos de Decodificación
struct MuseumRoomData: Codable {
    let id: Int?
    let nombre: String
    let posX: Double
    let posY: Double
    let width: Double
    let height: Double
    let exposiciones: [ExpositionData]
}

struct ExpositionData: Codable {
    let id: Int?
    let titulo: String
    let posX: Double
    let posY: Double
    let width: Double
    let height: Double
}
