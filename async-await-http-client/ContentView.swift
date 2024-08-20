//
//  ContentView.swift
//  async-await-http-client
//
//  Created by user on 2024-08-19.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var environmentModel: EnvironmentModel

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear() {
            environmentModel.fetchData()
        }
    }
}

#Preview {
    ContentView()
}
