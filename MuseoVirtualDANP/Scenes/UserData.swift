//
//  UserData.swift
//  MuseoVirtualDANP
//
//  Created by epismac on 16/10/24.
//

import Foundation
import SwiftUI

struct UserData: Codable, Identifiable{
    
    var id: UUID {UUID()}
    let gender: String
    let name: Name
    let location: Location
    let email: String
    let dob: DOB
    let phone: String
    let cell: String
    let picture: Picture
    
    
    struct Name: Codable {
        let title: String
        let first: String
        let last: String
    }
    
    struct Location: Codable {
        let street: Street
        let city: String
        let state: String
        let country: String
        let postcode: Int
        
        struct Street: Codable {
            let number: Int
            let name: String
        }
    }
    
    struct DOB: Codable {
        let date: String
        let age: Int
    }
    
    struct Picture: Codable {
        let large: String
    }
    
}
