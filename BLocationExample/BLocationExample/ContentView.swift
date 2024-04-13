//
//  ContentView.swift
//  BLocationExample
//
//  Created by Михаил Черников on 12.04.2024.
//

import BLocation
import SwiftUI

struct ContentModel {
    var blocation = BLocation(Secrets.apiKey)
}

struct ContentView: View {
    var model = ContentModel()

    var body: some View {
        VStack {
            BButton(title: "Start location updates") {
                Task {
                    try? await model.blocation.startUpdatingLocation()
                }
            }

            BButton(title: "Stop location updates") {
                model.blocation.stopUpdatingLocation()
            }
            .padding(3)
        }
        .padding()
    }
}

struct BButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(title, action: action)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .buttonStyle(.bordered)
    }
}

#Preview {
    ContentView()
}
