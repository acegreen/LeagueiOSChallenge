//
//  MockNetworkManager.swift
//  LeagueiOSChallengeTests
//
//  Created by AceGreen on 2025-02-18.
//

import Foundation
@testable import LeagueiOSChallenge

final class MockNetworkManager: NetworkManager {
    var shouldFailLogin = false
    var mockUser: User?
    var mockPosts: [Post] = []
    private var mockUsers: [Int: User] = [:]
    
    override func login(username: String, password: String) async throws {        
        if shouldFailLogin {
            throw NetworkError.invalidCredentials
        }
        
        // Set authorization state
        self.apiToken = "mock-token-\(username)"
        self.currentUser = mockUser
        self.userType = .loggedIn
    }
    
    override func continueAsGuest() async throws {        
        if shouldFailLogin {
            throw NetworkError.networkError(NSError(domain: "", code: -1))
        }
        
        // Set authorization state
        self.apiToken = "mock-guest-token"
        self.userType = .guest
        self.currentUser = nil
    }
    
    override func fetchPosts() async throws -> [Post] {        
        guard apiToken != nil else {
            throw NetworkError.unauthorized
        }
        
        return mockPosts
    }
    
    override func fetchUser(withId userId: Int) async throws -> User {
        guard apiToken != nil else {
            throw NetworkError.unauthorized
        }
        
        if let user = mockUsers[userId] {
            return user
        }
        
        let newUser = User(
            id: userId,
            name: "Test User \(userId)",
            username: "testuser\(userId)",
            email: "test\(userId)@invalid.me",
            avatar: "https://placekitten.com/200/200",
            website: "test.website",
            phone: "123-456-7890",
            address: nil,
            company: nil
        )
        mockUsers[userId] = newUser
        return newUser
    }
    
    override func logout() {
        userType = .none
        currentUser = nil
        apiToken = nil
    }
}

#if DEBUG
extension MockNetworkManager {
    static func configureForUITesting() -> MockNetworkManager {
        let mockManager = MockNetworkManager()
        
        // Create mock posts with a specific ID for testing
        mockManager.mockPosts = [
            Post(
                id: 1,
                userId: 1,
                title: "Test Post",
                body: "This is a test post description",
                imageURL: "https://placekitten.com/800/400"
            )
        ]
        
        // Create mock user with invalid email to trigger warning
        let mockUser = User(
            id: 1,
            name: "Test User",
            username: "testuser",
            email: "test@invalid.me", // Invalid email format to trigger warning
            avatar: "https://placekitten.com/200/200",
            website: "test.website",
            phone: "123-456-7890",
            address: nil,
            company: nil
        )
        
        mockManager.mockUser = mockUser
        mockManager.mockUsers[1] = mockUser
        
        return mockManager
    }
}
#endif 
