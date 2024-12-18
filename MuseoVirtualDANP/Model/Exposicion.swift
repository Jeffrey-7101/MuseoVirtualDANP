import Foundation

struct Exposicion: Identifiable, Codable {
    let id: Int
    let titulo: String
    let tecnica: String
    let categoria: String
    let descripcion: String
    let ano: Int
    let imagen: String?
    let audio: String?
    let posX: Double
    let posY: Double
    let width: Double
    let height: Double
    let bg_color: String
    let border_color: String
    let border: Bool
}

struct APIResponse: Codable {
    let results: [Exposicion]
    let next: String?
}
