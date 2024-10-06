//
//  ContentView.swift
//  MuseoVirtualDANP
//
//  Created by epismac on 3/10/24.
//

import SwiftUI
import CoreData

struct ContentView: View {
//    @Environment(\.managedObjectContext) private var viewContext
//
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Item>
//
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(items) { item in
//                    NavigationLink {
//                        Text("Item at \(item.timestamp!, formatter: itemFormatter)")
//                    } label: {
//                        Text(item.timestamp!, formatter: itemFormatter)
//                    }
//                }
//                .onDelete(perform: deleteItems)
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    EditButton()
//                }
//                ToolbarItem {
//                    Button(action: addItem) {
//                        Label("Add Item", systemImage: "plus")
//                    }
//                }
//            }
//            Text("Select an item")
//        }
//    }
//
//    private func addItem() {
//        withAnimation {
//            let newItem = Item(context: viewContext)
//            newItem.timestamp = Date()
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
    
    // Crear datos de ejemplo para el museo
    // Crear datos de ejemplo para el museo
    var rooms: [MuseumRoom] {
        [
//            MuseumRoom(name: "Sala 1", frame: CGRect(x: 50, y: 100, width: 150, height: 150), expositions: [
//                Exposition(name: "Pintura A", shape: .circle, relativeFrame: CGRect(x: 30, y: 30, width: 40, height: 40)), // Coordenadas relativas a la sala
//                Exposition(name: "Pintura B", shape: .rectangle, relativeFrame: CGRect(x: -20, y: 0, width: 10, height: 20))
//            ]),
//            MuseumRoom(name: "Sala 2", frame: CGRect(x: 250, y: 100, width: 150, height: 150), expositions: [
//                Exposition(name: "Pintura C", shape: .rectangle, relativeFrame: CGRect(x: 20, y: 50, width: 50, height: 30)),
//                Exposition(name: "Pintura D", shape: .circle, relativeFrame: CGRect(x: 90, y: 90, width: 40, height: 40))
//            ]),
//            MuseumRoom(name: "Sala 3", frame: CGRect(x: 150, y: 300, width: 150, height: 150), expositions: [
//                Exposition(name: "Pintura E", shape: .circle, relativeFrame: CGRect(x: 40, y: 50, width: 50, height: 50)),
//                Exposition(name: "Pintura F", shape: .rectangle, relativeFrame: CGRect(x: 100, y: 100, width: 60, height: 40))
//            ])
        ]
    }
    
    var body: some View {
        MuseumMapView(targetSize: CGSize(width: 400, height: 600))
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

//#Preview {
//    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
