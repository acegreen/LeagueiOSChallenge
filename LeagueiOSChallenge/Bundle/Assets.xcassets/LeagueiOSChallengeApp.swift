//
//  LeagueiOSChallengeApp.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

import SwiftUI

@main
struct LeagueiOSChallengeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(AuthenticationManager.shared)
        }
    }
} 