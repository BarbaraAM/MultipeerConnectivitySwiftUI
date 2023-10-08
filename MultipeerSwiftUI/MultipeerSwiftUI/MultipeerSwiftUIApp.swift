//
//  MultipeerSwiftUIApp.swift
//  MultipeerSwiftUI
//
//  Created by Barbara Argolo on 07/10/23.
//

import SwiftUI

@main
struct MultipeerSwiftUIApp: App {
    var connManager: ConnManager
    
    init() {
        connManager = ConnManager()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(connectionManager: connManager)
        }
    }
}
