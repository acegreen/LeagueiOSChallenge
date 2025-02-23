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
final class MockNetworkManager: NetworkManager {
    
    init(cacheManager: CacheManager = CacheManager()) {
        super.init(apiHelper: MockAPIHelper(), cacheManager: cacheManager)
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
    override func login(username: String, password: String) async throws {
        try await super.login(username: username, password: password)
    }
    
    /// Simulates guest login functionality
    /// - Throws: NetworkError for network failures
    override func continueAsGuest() async throws {
        self.apiToken = "mock-guest-token"
        self.userType = .guest
        
        // Load all users into cache
        try await loadAllUsers()
    }
    
    /// Returns mock posts for testing
    /// - Returns: Array of mock Post objects
    /// - Throws: NetworkError.unauthorized if no valid token exists
    override func fetchPosts(withId: Int? = nil) async throws -> [Post] {
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
    override func fetchUser(withId userId: Int) async throws -> User {
        guard apiToken != nil else {
            throw NetworkError.unauthorized
        }
        
        return createMockUser(id: userId, username: "testuser\(userId)")
    }
    
    /// Simulates logout by clearing all mock authentication state
    override func logout() {
        userType = .none
        currentUser = nil
        apiToken = nil
    }
}
