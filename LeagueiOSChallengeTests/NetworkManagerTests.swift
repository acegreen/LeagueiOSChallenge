//
//  LeagueiOSChallengeTests.swift
//  LeagueiOSChallengeTests
//
//  Created by AceGreen on 2025-02-18.
//

import XCTest
@testable import LeagueiOSChallenge

final class NetworkManagerTests: XCTestCase {
    var mockNetworkManager: MockNetworkManager!
    
    override func setUp() {
        super.setUp()
        mockNetworkManager = MockNetworkManager()
        mockNetworkManager.mockUser = User(
            id: 1,
            name: "Test User",
            username: "testuser",
            email: "test@example.com",
            avatar: nil,
            website: nil,
            phone: nil,
            address: nil,
            company: nil
        )
    }
    
    override func tearDown() {
        mockNetworkManager.logout()
        super.tearDown()
    }
    
    func testGuestLogin() async throws {
        // Test guest login
        try await mockNetworkManager.continueAsGuest()
        
        XCTAssertEqual(mockNetworkManager.userType, .guest)
        XCTAssertNil(mockNetworkManager.currentUser)
        XCTAssertNotNil(mockNetworkManager.apiToken)
    }
    
    func testUserLogin() async throws {
        // Test valid login
        try await mockNetworkManager.login(username: "testUser", password: "testPass")
        
        XCTAssertEqual(mockNetworkManager.userType, .loggedIn)
        XCTAssertNotNil(mockNetworkManager.currentUser)
        XCTAssertNotNil(mockNetworkManager.apiToken)
    }
    
    func testInvalidLogin() async {
        // Configure mock to fail login
        mockNetworkManager.shouldFailLogin = true
        
        // Test invalid login
        do {
            try await mockNetworkManager.login(username: "invalid", password: "invalid")
            XCTFail("Login should have failed")
        } catch {
            XCTAssertTrue(error is NetworkError)
            if case NetworkError.invalidCredentials = error {
                // Expected error
            } else {
                XCTFail("Unexpected error type: \(error)")
            }
        }
    }
    
    func testUserCache() async throws {
        // Login first
        try await mockNetworkManager.continueAsGuest()
        
        // Fetch user twice
        let userId = 1
        let firstUser = try await mockNetworkManager.fetchUser(withId: userId)
        let secondUser = try await mockNetworkManager.fetchUser(withId: userId)
        
        // Should be the same user
        XCTAssertEqual(firstUser.id, secondUser.id)
        XCTAssertEqual(firstUser.username, secondUser.username)
    }
    
    func testLogout() async throws {
        // Login first
        try await mockNetworkManager.continueAsGuest()
        
        // Then logout
        mockNetworkManager.logout()
        
        XCTAssertEqual(mockNetworkManager.userType, .none)
        XCTAssertNil(mockNetworkManager.currentUser)
        XCTAssertNil(mockNetworkManager.apiToken)
    }
}
