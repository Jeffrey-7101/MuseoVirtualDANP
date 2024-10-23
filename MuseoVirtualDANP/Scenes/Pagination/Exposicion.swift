//
//  Exposicion.swift
//  MuseoVirtualDANP
//
//  Created by MacEpis on 22/10/24.
//

import Foundation

// Modelo para cada exposicion
struct ExposicionDate: Decodable, Identifiable, Equatable {
    let id: Int
    let titulo: String
    let tecnica: String
    let categoria: String
    let descripcion: String
    let ano: Int
    let sala: Int
    let bg_color: String
    let border_color: String
    let border: Bool
    let imagen: String?
}

// Modelo APIResponse
struct APIResponse: Decodable {
    let count: Int
    let next: String?
    let previus: String?
    let results: [ExposicionDate]
}
