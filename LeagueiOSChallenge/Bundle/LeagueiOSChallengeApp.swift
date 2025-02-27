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
    @State private var networkContainer: NetworkContainer = {
        let manager: NetworkManagerProtocol = ProcessInfo.processInfo.arguments.contains("UI-Testing")
            ? MockNetworkManager()
            : NetworkManager()
        return NetworkContainer(manager: manager)
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(networkContainer)
                .tint(Color.accentColor)
        }
    }
}
