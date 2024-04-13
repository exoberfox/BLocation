//
//  ContentView.swift
//  BLocationExample
//
//  Created by Михаил Черников on 12.04.2024.
//

import BLocation
import SwiftUI

struct ContentView: View {
    @StateObject
    var model = BLocationAdapter()

    var body: some View {
        VStack {
            Text(model.state.rawValue)

            BButton(title: "Setup sdk") {
                model.setup()
            }

            BButton(title: "Start location updates") {
                model.start()
            }

            BButton(title: "Stop location updates") {
                model.stop()
            }
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
