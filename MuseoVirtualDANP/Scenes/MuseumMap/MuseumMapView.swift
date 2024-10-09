import SwiftUI
import CoreData

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Estructura del Modelo
struct MuseumRoom {
    let id: UUID
    let name: String
    let frame: CGRect
    let bgColor: String
    let borderColor: String
    let drawBorder: Bool
    
    var expositions: [Exposition]
}

struct Exposition {
    let id: UUID
    let name: String
    let shape: ShapeType
    
    let bgColor: String
    let borderColor: String
    let drawBorder: Bool
    
    let relativeFrame: CGRect
    
    
    
    
    enum ShapeType {
        case rectangle
    }
}

struct ExpositionView: View {
    let exposition: Exposition
    let roomOrigin: CGPoint
    let scale: CGFloat
    let bgColor: String
    let onTap: () -> Void

    var body: some View {
        Rectangle()
            .fill(Color(hex: bgColor))
            .frame(width: exposition.relativeFrame.width * scale, height: exposition.relativeFrame.height * scale)
            .position(x: (roomOrigin.x + exposition.relativeFrame.midX) * scale, y: (roomOrigin.y + exposition.relativeFrame.midY) * scale)
            .onTapGesture {
                onTap()
            }
    }
}

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
                .strokeBorder(Color(hex: room.borderColor), lineWidth: room.drawBorder ? 3 : 0)
                .background(Rectangle().fill(Color(hex: room.bgColor).opacity(0.9)))
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
                ExpositionView(exposition: exposition, roomOrigin: adjustedOrigin, scale: scale, bgColor: exposition.bgColor) {
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
                    bgColor: room.bg_color ?? "#008800",
                    borderColor: room.border_color ?? "#008850",
                    drawBorder: room.border,
                    expositions: expositions.map { exposition in
                        Exposition(
                            id: exposition.id!,
                            name: exposition.name ?? "vaa",
                            shape: .rectangle, // Por defecto todas las exposiciones serán rectángulos
                            bgColor: exposition.bg_color ?? "#008800",
                            borderColor: exposition.border_color ?? "#508800",
                            drawBorder: exposition.border,
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

func saveRoomsToCoreData(_ roomsData: [MuseumRoomData]) {
    let context = PersistenceController.shared.container.viewContext

    for roomData in roomsData {
        // Buscar si ya existe un objeto MuseumRoomEntity con el mismo integer_id
        let fetchRoomRequest: NSFetchRequest<MuseumRoomEntity> = MuseumRoomEntity.fetchRequest()
        fetchRoomRequest.predicate = NSPredicate(format: "integer_id == %d", roomData.id!)

        do {
            let fetchedRooms = try context.fetch(fetchRoomRequest)
            let roomEntity: MuseumRoomEntity

            // Si ya existe una sala con el mismo integer_id, actualizamos
            if let existingRoom = fetchedRooms.first {
                roomEntity = existingRoom
                roomEntity.name = roomData.nombre
                roomEntity.posX = roomData.posX
                roomEntity.posY = roomData.posY
                roomEntity.width = roomData.width
                roomEntity.height = roomData.height
                
                roomEntity.bg_color = roomData.bg_color
                roomEntity.border_color = roomData.border_color
                roomEntity.border = roomData.border
                print("Updating existing room with integer_id \(roomData.id!)")
            } else {
                // Si no existe, creamos una nueva entidad
                roomEntity = MuseumRoomEntity(context: context)
                roomEntity.id = UUID(uuidString: String(roomData.id!)) ?? UUID()
                roomEntity.integer_id = roomData.id!
                roomEntity.name = roomData.nombre
                roomEntity.posX = roomData.posX
                roomEntity.posY = roomData.posY
                roomEntity.width = roomData.width
                roomEntity.height = roomData.height
                
                
                roomEntity.bg_color = roomData.bg_color
                roomEntity.border_color = roomData.border_color
                roomEntity.border = roomData.border
                print("Creating new room with integer_id \(roomData.id!)")
            }

            // Iterar sobre las exposiciones de la sala
            for expositionData in roomData.exposiciones {
                // Buscar si ya existe un objeto ExpositionEntity con el mismo integer_id
                let fetchExpositionRequest: NSFetchRequest<ExpositionEntity> = ExpositionEntity.fetchRequest()
                fetchExpositionRequest.predicate = NSPredicate(format: "integer_id == %d", expositionData.id!)

                let fetchedExpositions = try context.fetch(fetchExpositionRequest)
                let expositionEntity: ExpositionEntity

                // Si ya existe una exposición con el mismo integer_id, actualizamos
                if let existingExposition = fetchedExpositions.first {
                    expositionEntity = existingExposition
                    expositionEntity.name = expositionData.titulo
                    expositionEntity.posX = expositionData.posX
                    expositionEntity.posY = expositionData.posY
                    expositionEntity.width = expositionData.width
                    expositionEntity.height = expositionData.height
                    
                    
                    expositionEntity.bg_color = expositionData.bg_color
                    expositionEntity.border_color = expositionData.border_color
                    expositionEntity.border = expositionData.border
                    print("Updating existing exposition with integer_id \(expositionData.id!)")
                } else {
                    // Si no existe, creamos una nueva entidad
                    expositionEntity = ExpositionEntity(context: context)
                    expositionEntity.id = UUID(uuidString: String(expositionData.id!)) ?? UUID()
                    expositionEntity.integer_id = expositionData.id!
                    expositionEntity.name = expositionData.titulo
                    expositionEntity.posX = expositionData.posX
                    expositionEntity.posY = expositionData.posY
                    expositionEntity.width = expositionData.width
                    expositionEntity.height = expositionData.height
                    
                    expositionEntity.bg_color = expositionData.bg_color
                    expositionEntity.border_color = expositionData.border_color
                    expositionEntity.border = expositionData.border
                    print("Creating new exposition with integer_id \(expositionData.id!)")
                }

                // Agregar la relación entre la sala y la exposición
                roomEntity.addToExpositions(expositionEntity)
            }

            // Guardar los cambios en el contexto
            try context.save()
        } catch {
            print("Error al intentar guardar o actualizar la entidad: \(error)")
        }
    }
}

// MARK: - Modelos de Decodificación
struct MuseumRoomData: Codable {
    let id: Int64?
    let nombre: String
    let posX: Double
    let posY: Double
    let width: Double
    let height: Double
    let exposiciones: [ExpositionData]
    let bg_color: String
    let border_color: String
    let border: Bool
}

struct ExpositionData: Codable {
    let id: Int64?
    let titulo: String
    let posX: Double
    let posY: Double
    let width: Double
    let height: Double
    let bg_color: String
    let border_color: String
    let border: Bool
}

