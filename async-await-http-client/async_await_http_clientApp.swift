//
//  async_await_http_clientApp.swift
//  async-await-http-client
//
//  Created by user on 2024-08-19.
//

import SwiftUI

@main
struct async_await_http_clientApp: App {

    @StateObject private var environmentModel = EnvironmentModel()

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(environmentModel)
        }
    }
}
