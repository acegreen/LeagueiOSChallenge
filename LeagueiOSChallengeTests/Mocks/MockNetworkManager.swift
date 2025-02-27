//
//  MockNetworkManager.swift
//  LeagueiOSChallengeTests
//
//  Created by AceGreen on 2025-02-18.
//

import Foundation
@testable import LeagueiOSChallenge

/// Mock implementation of NetworkManager for testing purposes
/// Provides controlled responses and error states for testing network operations
class MockNetworkManager: NetworkManagerProtocol {
    var userType: User.UserType = .none
    var currentUser: User?
    var apiToken: String?

    private let cacheManager: CacheManager

    init(cacheManager: CacheManager = CacheManager()) {
        self.cacheManager = cacheManager
    }
    
    private func createMockUser(id: Int, username: String) -> User {
        User(
            id: id,
            name: "Test User \(id)",
            username: username,
            email: "test\(id)@example.ca",
            avatar: "https://placehold.co/200x200",
            website: "test.website",
            phone: "123-456-7890",
            address: nil,
            company: nil
        )
    }
    
    /// Simulates user login with mock credentials
    /// - Parameters:
    ///   - username: Test username ("invalid" for testing invalid credentials)
    ///   - password: Test password
    /// - Throws: NetworkError.invalidCredentials when username is "invalid"
    func login(username: String, password: String) async throws {
        if username == "invalid" {
            throw NetworkError.invalidCredentials
        }
        
        self.apiToken = "mock-token"
        self.userType = .loggedIn
        self.currentUser = createMockUser(id: 1, username: username)
    }
    
    /// Simulates guest login functionality
    /// - Throws: NetworkError for network failures
    func continueAsGuest() async throws {
        self.apiToken = "mock-guest-token"
        self.userType = .guest
    }
    
    /// Returns mock posts for testing
    /// - Returns: Array of mock Post objects
    /// - Throws: NetworkError.unauthorized if no valid token exists
    func fetchPosts(withId userId: Int? = nil) async throws -> [Post] {
        guard apiToken != nil else {
            throw NetworkError.unauthorized
        }
        
        return [
            Post(
                id: 1,
                userId: 1,
                title: "Test Post",
                body: "This is a test post description",
                imageURL: "https://placehold.co/200x200"
            )
        ]
    }
    
    /// Retrieves or creates a mock user for testing
    /// - Parameter userId: The ID of the mock user to fetch
    /// - Returns: A mock User object
    /// - Throws: NetworkError.unauthorized if no valid token exists
    func fetchUser(withId userId: Int) async throws -> User {
        guard apiToken != nil else {
            throw NetworkError.unauthorized
        }
        
        return createMockUser(id: userId, username: "testuser\(userId)")
    }
    
    /// Simulates logout by clearing all mock authentication state
    func logout() {
        userType = .none
        currentUser = nil
        apiToken = nil
    }
}
