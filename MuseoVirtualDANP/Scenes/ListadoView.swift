//
//  ListView.swift
//  MuseoVirtualDANP
//
//  Created by MacEpis on 16/10/24.
//

import SwiftUI

struct ListadoView: View {
    var body: some View {
        List {
            Text("Elemento 1")
            Text("Elemento 2")
            Text("Elemento 3")
        }
        .navigationTitle("Listado")
    }
}

