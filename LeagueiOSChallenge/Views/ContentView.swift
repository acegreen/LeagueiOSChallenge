//
//  ContentView.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

import SwiftUI

struct ContentView: View {
    @Environment(NetworkContainer.self) var networkContainer
    
    var body: some View {
        Group {
            switch networkContainer.userType {
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
        .environment(NetworkContainer(manager: MockNetworkManager()))
}
