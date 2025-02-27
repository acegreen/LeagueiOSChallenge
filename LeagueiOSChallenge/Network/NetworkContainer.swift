//
//  NetworkManager.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-20.
//

import SwiftUI
import Observation

@Observable
class NetworkContainer {
    var manager: NetworkManagerProtocol
    
    init(manager: NetworkManagerProtocol) {
        self.manager = manager
    }
    
    // Forward all the protocol requirements
    var userType: User.UserType {
        get { manager.userType }
        set { manager.userType = newValue }
    }
    
    var currentUser: User? {
        get { manager.currentUser }
        set { manager.currentUser = newValue }
    }
    
    var apiToken: String? {
        get { manager.apiToken }
        set { manager.apiToken = newValue }
    }
    
    func login(username: String, password: String) async throws {
        try await manager.login(username: username, password: password)
    }
    
    func fetchPosts(withId userId: Int?) async throws -> [Post] {
        try await manager.fetchPosts(withId: userId)
    }
    
    func fetchUser(withId userId: Int) async throws -> User {
        try await manager.fetchUser(withId: userId)
    }
    
    func continueAsGuest() async throws {
        try await manager.continueAsGuest()
    }
    
    func logout() {
        manager.logout()
    }
} 
