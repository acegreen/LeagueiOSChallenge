//
//  LeagueiOSChallengeApp.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

import SwiftUI
import Observation

@main
struct LeagueiOSChallengeApp: App {
    @State private var networkManager: NetworkManager = {
        if ProcessInfo.processInfo.arguments.contains("UI-Testing") {
            return MockNetworkManager()
        }
        return NetworkManager(apiHelper: APIHelper())
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(networkManager)
                .tint(Color.accentColor)
        }
    }
}
