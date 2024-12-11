//
//  MuseumData.swift
//  MuseoVirtualDANP
//
//  Created by MacEpis on 6/10/24.
//

import SwiftUI

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
                            // Mapear el JSON a la estructura MuseumRoom
                            guard let id = roomJSON["id"] as? Int,
                                  let name = roomJSON["nombre"] as? String,
                                  let description = roomJSON["descripcion"] as? String,
                                  let posX = roomJSON["posX"] as? Double,
                                  let posY = roomJSON["posY"] as? Double,
                                  let width = roomJSON["width"] as? Double,
                                  let height = roomJSON["height"] as? Double,
                                  let expositionsJSON = roomJSON["exposiciones"] as? [[String: Any]] else {
                                return nil
                            }

                            // Mapear las exposiciones
                            let expositions = expositionsJSON.compactMap { expoJSON in
                                guard let expoId = expoJSON["id"] as? Int,
                                      let title = expoJSON["titulo"] as? String,
                                      let posX = expoJSON["posX"] as? Double,
                                      let posY = expoJSON["posY"] as? Double,
                                      let width = expoJSON["width"] as? Double,
                                      let height = expoJSON["height"] as? Double,
                                      let imageURLString = expoJSON["imagen"] as? String else {
                                    return nil
                                }
                                
                                let shape: Exposition.ShapeType = (width == height) ? .circle : .rectangle
                                let imageURL = URL(string: imageURLString)
                                
                                return Exposition(
                                    id: expoId,
                                    name: title,
                                    description: expoJSON["descripcion"] as? String ?? "",
                                    shape: shape,
                                    relativeFrame: CGRect(x: posX, y: posY, width: width, height: height),
                                    imageURL: imageURL
                                )
                            }
                            
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
