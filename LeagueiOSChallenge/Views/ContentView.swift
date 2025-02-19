//
//  ContentView.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

import SwiftUI

struct ContentView: View {
    @Environment(NetworkManager.self) private var networkManager
    
    var body: some View {
        Group {
            switch networkManager.userType {
            case .none:
                LoginView()
            case .loggedIn, .guest:
                PostListView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(MockNetworkManager.configureForUITesting())
}
