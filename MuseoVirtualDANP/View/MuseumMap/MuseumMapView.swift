import SwiftUI
import CoreData

// MARK: - Model Structures for Display
struct MuseumRoom {
    let id: UUID
    let name: String
    let frame: CGRect
    let bgColor: String
    let borderColor: String
    let drawBorder: Bool
    var expositions: [ExpositionViewData]
}

struct ExpositionViewData {
    let id: UUID
    let shape: ShapeType
    let relativeFrame: CGRect
    let exposition: Exposicion
    
    enum ShapeType {
        case rectangle
    }
}

// MARK: - Exposition View

// View to display a single exposition within a room
struct ExpositionView: View {
    let expositionData: ExpositionViewData      // The exposition to display
    let roomOrigin: CGPoint         // The origin point of the room
    let scale: CGFloat              // The scale factor for adjusting size and position
    let onTap: () -> Void           // Action to perform when the exposition is tapped

    var body: some View {
        Rectangle()                                                     // Draw a rectangle for the exposition
            .fill(Color(hex: expositionData.exposition.bg_color))                      // Fill the rectangle with the specified background color
            .frame(
                width: expositionData.relativeFrame.width * scale,        // Scale the width based on the scale factor
                height: expositionData.relativeFrame.height * scale       // Scale the height based on the scale factor
            )
            .position(
                x: (roomOrigin.x + expositionData.relativeFrame.midX) * scale,  // Calculate x-position with scaling
                y: (roomOrigin.y + expositionData.relativeFrame.midY) * scale   // Calculate y-position with scaling
            )
            .onTapGesture {                                            // Handle tap gesture
                onTap()                                                // Trigger the tap action
            }
    }
}

// MARK: - Room View

// View to display a single museum room with its expositions
struct RoomView: View {
    let room: MuseumRoom                        // The room to display
    let scale: CGFloat                          // The scale factor for adjusting size and position
    let isSelected: Bool                        // Flag to determine if the room is selected
    let adjustedOrigin: CGPoint                 // The adjusted origin point for the room
    let onTapRoom: () -> Void                   // Action to perform when the room is tapped
    let onTapExposition: (ExpositionViewData) -> Void   // Action to perform when an exposition is tapped

    var body: some View {
        
        ZStack {                                                    // Overlay elements in a stack
            // Draw the room with optional border
            Rectangle()
                .strokeBorder(Color(hex: room.borderColor), lineWidth: room.drawBorder ? 3 : 0) // Draw border if `drawBorder` is true
                .background(Rectangle().fill(Color(hex: room.bgColor).opacity(0.9)))           // Fill the background with specified color
                .frame(
                    width: room.frame.width * scale,    // Scale the room width
                    height: room.frame.height * scale   // Scale the room height
                )
                .position(
                    x: (adjustedOrigin.x + room.frame.width / 2) * scale, // Calculate x-position for room
                    y: (adjustedOrigin.y + room.frame.height / 2) * scale // Calculate y-position for room
                )
                .onTapGesture {
                    onTapRoom()                            // Trigger the room tap action
                }
                .animation(.easeInOut, value: isSelected)  // Animate changes when the room is selected or deselected
            
            // Display the room name in the center
            Text(room.name)
                .font(.caption)                          // Use a small font size
                .bold()                                  // Make the text bold
                .foregroundColor(.black)                // Set the text color to black
                .position(
                    x: (adjustedOrigin.x + room.frame.width / 2) * scale, // Align the text horizontally
                    y: (adjustedOrigin.y + room.frame.height / 2) * scale // Align the text vertically
                )
            
            // Display all expositions within the room
            ForEach(room.expositions, id: \ .id) { exposition in
                ExpositionView(
                    expositionData: exposition,               // Pass the exposition to the view
                    roomOrigin: adjustedOrigin,           // Use the adjusted room origin
                    scale: scale,                         // Apply the scale factor
                    onTap: {
                        onTapExposition(exposition)       // Trigger the exposition tap action
                    }
                )
            }
        }
    }
}

// MARK: - Museum Map View

// Main view to display the entire museum map with rooms and expositions
struct MuseumMapView: View {
    @FetchRequest(
        entity: MuseumRoomEntity.entity(),
        sortDescriptors: []
    ) var rooms: FetchedResults<MuseumRoomEntity>      // Fetch request to retrieve room data from CoreData
    
    public let targetSize: CGSize                            // The target size of the museum map view
    @State private var selectedRoom: UUID? = nil      // State to track which room is selected
    
    @State private var isLinkActive = false
    @State private var selectedExposition:Exposicion = Exposicion(id: 0, titulo: "", tecnica: "", categoria: "", descripcion: "", ano: 0, imagen: "", audio: "", posX: 0, posY: 0, width: 0, height: 0, bg_color: "", border_color: "", border: false)
    
    var body: some View {
        let originalSize = CGSize(width: 11, height: 23) // Original map size for scaling reference
        let scale = min(targetSize.width / originalSize.width, targetSize.height / originalSize.height) // Calculate the scale factor
        
        // Sort rooms so the selected room is drawn on top
        let sortedRooms = rooms.sorted { room1, room2 in
            // If a room is selected, draw the selected room last
            if let selectedRoom = selectedRoom {
                return room1.id != selectedRoom && room2.id == selectedRoom
            }
            // Default sorting if no room is selected
            return true
        }
        
        ZStack {                                        // Stack rooms on top of each other
            ForEach(sortedRooms, id: \ .id) { room in
                let expositions = (room.expositions?.allObjects as? [ExpositionEntity]) ?? [] // Extract expositions from the CoreData entity
                let museumRoom = mapRoomEntityToModel(room, expositions: expositions)          // Convert CoreData entity to model
                
                let isSelected = selectedRoom == room.id // Check if the current room is selected
                let maxScale = min(targetSize.width / museumRoom.frame.width, targetSize.height / museumRoom.frame.height) // Calculate max scale for selected room
                
                // Center the room vertically when selected
                let adjustedOrigin: CGPoint = isSelected ?
                CGPoint(x: (targetSize.width - museumRoom.frame.width * maxScale) / 2 / maxScale, y: (targetSize.height - museumRoom.frame.height * maxScale) / 2 / maxScale):
                museumRoom.frame.origin
                
                
                RoomView(
                    room: museumRoom,
                    scale: isSelected ? maxScale : scale,  // Use max scale if the room is selected
                    isSelected: isSelected,
                    adjustedOrigin: adjustedOrigin,
                    onTapRoom: {
                        withAnimation(.easeInOut) {        // Animate the selection/deselection
                            selectedRoom = selectedRoom == room.id ? nil : room.id
                        }
                    },
                    onTapExposition: { exposition in
                        print("Selected exposition: \(exposition.exposition.titulo)") // Print the name of the selected exposition
                        self.selectedExposition = exposition.exposition
                        self.isLinkActive = true
                    }
                )
            }
        }
        .frame(width: targetSize.width, height: targetSize.height) // Set the frame size of the map
        .onAppear {
            fetchMuseumData()                      // Fetch the initial museum data when the view appears
        } 
        .background(
            NavigationLink(destination: ExposicionDetalleView(exposicionId: self.selectedExposition.id), isActive: $isLinkActive) {
                EmptyView()
            }
            .hidden()
        )
    }
}



// MARK: - Utility for Mapping Entities to Models
func mapRoomEntityToModel(_ room: MuseumRoomEntity, expositions: [ExpositionEntity]) -> MuseumRoom {
    MuseumRoom(
        id: room.id ?? UUID(),
        name: room.name ?? "Unnamed Room",
        frame: CGRect(x: room.posX, y: room.posY, width: room.width, height: room.height),
        bgColor: room.bg_color ?? "#008800",
        borderColor: room.border_color ?? "#008850",
        drawBorder: room.border,
        expositions: expositions.map {
            ExpositionViewData(
                id: $0.id ?? UUID(),
                shape: .rectangle,
                relativeFrame: CGRect(x: $0.posX, y: $0.posY, width: $0.width, height: $0.height),
                exposition: Exposicion(
                    id: Int($0.integer_id),
                    titulo: $0.name ?? "Unnamed Exposition",
                    tecnica: $0.tecnica ?? "",  // Fill with actual data if available
                    categoria: $0.categoria ?? "", // Fill with actual data if available
                    descripcion: $0.descripcion ?? "", // Fill with actual data if available
                    ano: Int($0.ano), // Fill with actual data if available
                    imagen: $0.imagen,
                    audio: $0.audio,
                    posX: $0.posX,
                    posY: $0.posY,
                    width: $0.width,
                    height: $0.height,
                    bg_color: $0.bg_color ?? "#008800",
                    border_color: $0.border_color ?? "#508800",
                    border: $0.border
                )
            )
        }
    )
}



// MARK: - API Fetching Function
func fetchMuseumData() {
    guard let url = URL(string: "https://museo.epis-dev.site/api/museo/salas/") else { return }
    
    URLSession.shared.dataTask(with: url) { data, _, error in
        if let error = error {
            print("Error fetching data: \(error.localizedDescription)")
            return
        }
        
        guard let data = data else { return }
        print(data)
        
        let decoder = JSONDecoder()
        do {
            print("start decode")
            let roomsData = try decoder.decode([MuseumRoomData].self, from: data)
            print("end decode")
            saveRoomsToCoreData(roomsData)
        } catch {
            print("Error ????? decoding data: \(error.localizedDescription)")
        }
    }.resume()
}

// MARK: - Core Data Persistence Function
func saveRoomsToCoreData(_ roomsData: [MuseumRoomData]) {
    let context = PersistenceController.shared.container.viewContext
    
    context.perform {
        do {
            for roomData in roomsData {
                let roomEntity = fetchOrCreateRoomEntity(roomData: roomData, in: context)
                
                for expositionData in roomData.exposiciones {
                    let _ = fetchOrCreateExpositionEntity(expositionData: expositionData, in: context, parentRoom: roomEntity)
                }
            }
            
            try context.save()
        } catch {
            print("Error saving data: \(error.localizedDescription)")
        }
    }
}

// Helper function to fetch or create a room entity
func fetchOrCreateRoomEntity(roomData: MuseumRoomData, in context: NSManagedObjectContext) -> MuseumRoomEntity {
    let request: NSFetchRequest<MuseumRoomEntity> = MuseumRoomEntity.fetchRequest()
    request.predicate = NSPredicate(format: "integer_id == %d", roomData.id!)
    
    let roomEntity = (try? context.fetch(request).first) ?? MuseumRoomEntity(context: context)
    roomEntity.id = UUID()
    roomEntity.integer_id = roomData.id!
    roomEntity.name = roomData.nombre
    roomEntity.descripcion = roomData.descripcion
    roomEntity.imagen = roomData.imagen
    roomEntity.posX = roomData.posX
    roomEntity.posY = roomData.posY
    roomEntity.width = roomData.width
    roomEntity.height = roomData.height
    roomEntity.bg_color = roomData.bg_color
    roomEntity.border_color = roomData.border_color
    roomEntity.border = roomData.border
    
    return roomEntity
}

func fetchOrCreateExpositionEntity(expositionData: ExpositionData, in context: NSManagedObjectContext, parentRoom: MuseumRoomEntity) -> ExpositionEntity {
    let fetchRequest: NSFetchRequest<ExpositionEntity> = ExpositionEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "integer_id == %d", expositionData.id!)

    print("start create exp")
    do {
        let fetchedExpositions = try context.fetch(fetchRequest)
        let expositionEntity = fetchedExpositions.first ?? ExpositionEntity(context: context)
        
        expositionEntity.id = UUID()
        expositionEntity.integer_id = expositionData.id!
        expositionEntity.name = expositionData.titulo
        expositionEntity.tecnica = expositionData.tecnica
        expositionEntity.categoria = expositionData.categoria
        expositionEntity.descripcion = expositionData.descripcion
        expositionEntity.ano = Int64(expositionData.ano)
        expositionEntity.imagen = expositionData.imagen
        expositionEntity.posX = expositionData.posX
        expositionEntity.posY = expositionData.posY
        expositionEntity.width = expositionData.width
        expositionEntity.height = expositionData.height
        expositionEntity.bg_color = expositionData.bg_color
        expositionEntity.border_color = expositionData.border_color
        expositionEntity.border = expositionData.border
        expositionEntity.absolute_position = expositionData.absolute_position
        expositionEntity.autor = expositionData.autor
        expositionEntity.audio = expositionData.audio
        
        print("creating")

        if !parentRoom.expositions!.contains(expositionEntity) {
            parentRoom.addToExpositions(expositionEntity)
        }

        return expositionEntity
    } catch {
        fatalError("Failed to fetch or create ExpositionEntity: \(error)")
    }
}

// MARK: - Modelos de Decodificación
struct MuseumRoomData: Codable {
    let id: Int64?
    let nombre: String
    let descripcion: String
    let imagen: String?
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
    let tecnica: String
    let categoria: String
    let descripcion: String
    let ano: Int
    let imagen: String?
    let posX: Double
    let posY: Double
    let width: Double
    let height: Double
    let bg_color: String
    let border_color: String
    let border: Bool
    let absolute_position: Bool
    let autor: String
    let audio: String?
}


