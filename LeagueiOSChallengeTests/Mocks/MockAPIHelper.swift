//
//  MockAPIHelper.swift
//  LeagueiOSChallengeTests
//
//  Created by AceGreen on 2025-02-18.
//

import Foundation
@testable import LeagueiOSChallenge

class MockAPIHelper: APIHelper {
    override func fetchUserToken(username: String, password: String) async throws -> String {
        if username == "invalid" {
            throw APIError.unauthorized
        }
        return "mock-token-\(username)"
    }
    
    override func fetchPosts(token: String, userId: Int? = nil) async throws -> [Post] {
        guard token.hasPrefix("mock-token-") || token == "mock-guest-token" else {
            throw NetworkError.unauthorized
        }
        
        let posts = [
            Post(
                id: 1,
                userId: 1,
                title: "Test Post 1",
                body: "This is test post 1 description",
                imageURL: "https://placehold.co/200x200"
            ),
            Post(
                id: 2,
                userId: 2,
                title: "Test Post 2",
                body: "This is test post 2 description",
                imageURL: "https://placehold.co/200x200"
            )
        ]
        
        if let userId = userId {
            return posts.filter { $0.userId == userId }
        }
        
        return posts
    }
    
    override func fetchUsers(token: String) async throws -> [User] {
        guard token.hasPrefix("mock-token-") || token == "mock-guest-token" else {
            throw NetworkError.unauthorized
        }
        
        return [
            User(
                id: 1,
                name: "Test User 1",
                username: "testuser1",
                email: "test1@example.ca",
                avatar: "https://placehold.co/200x200",
                website: "test1.website",
                phone: "123-456-7890",
                address: nil,
                company: nil
            ),
            User(
                id: 2,
                name: "Test User 2",
                username: "testuser2",
                email: "test2@example.ca",
                avatar: "https://placehold.co/200x200",
                website: "test2.website",
                phone: "123-456-7890",
                address: nil,
                company: nil
            )
        ]
    }
} 
