//
//  MockNetworkManager.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

@testable import LeagueiOSChallenge
import Foundation

@Observable
final class MockNetworkManager: NetworkManagerProtocol {
    var userType: User.UserType = .none
    var currentUser: User?
    var apiToken: String?
    
    var shouldFailLogin = false
    var mockUser: User?
    var mockPosts: [Post] = []
    
    func login(username: String, password: String) async throws {
        if shouldFailLogin {
            throw NetworkError.invalidCredentials
        }
        
        self.apiToken = "mock-token"
        self.currentUser = mockUser
        self.userType = .loggedIn
    }
    
    func continueAsGuest() async throws {
        if shouldFailLogin {
            throw NetworkError.networkError(NSError(domain: "", code: -1))
        }
        
        self.apiToken = "mock-guest-token"
        self.userType = .guest
    }
    
    func fetchPosts() async throws -> [Post] {
        if apiToken == nil {
            throw NetworkError.unauthorized
        }
        return mockPosts
    }
    
    func fetchUser(withId userId: Int) async throws -> User {
        if apiToken == nil {
            throw NetworkError.unauthorized
        }
        
        guard let user = mockUser, user.id == userId else {
            throw NetworkError.networkError(NSError(domain: "", code: -1))
        }
        
        return user
    }
    
    func logout() {
        userType = .none
        currentUser = nil
        apiToken = nil
    }
} 