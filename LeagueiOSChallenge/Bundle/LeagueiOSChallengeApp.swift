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
    @State private var cacheManager = CacheManager()
    @State private var networkManager: NetworkManager = {
        let cacheManager = CacheManager()
        if ProcessInfo.processInfo.arguments.contains("UI-Testing") {
            return MockNetworkManager(cacheManager: cacheManager)
        }
        return NetworkManager(apiHelper: APIHelper(), cacheManager: cacheManager)
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(networkManager)
                .environment(cacheManager)
                .tint(Color.accentColor)
        }
    }
}
