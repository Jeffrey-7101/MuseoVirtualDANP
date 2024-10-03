//
//  MuseoVirtualDANPApp.swift
//  MuseoVirtualDANP
//
//  Created by epismac on 3/10/24.
//

import SwiftUI

@main
struct MuseoVirtualDANPApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
