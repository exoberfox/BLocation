//
//  ContentView.swift
//  BLocationExample
//
//  Created by Михаил Черников on 12.04.2024.
//

import BLocation
import SwiftUI

struct ContentModel {
    var blocation = BLocation()
}

struct ContentView: View {
    var model = ContentModel()

    var body: some View {
        VStack {
            Button("Request location permission") {
                model.blocation.requestLocationPermission()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
