//
//  ContentView.swift
//  BLocationExample
//
//  Created by Михаил Черников on 12.04.2024.
//

import BLocation
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.blue)
            Text("Hello, world!")
        }
        .padding()
        .task {
            _ = BLocation()
        }
    }
}

#Preview {
    ContentView()
}
