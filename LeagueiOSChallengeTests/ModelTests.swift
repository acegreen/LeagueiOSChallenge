//
//  ModelTests.swift
//  LeagueiOSChallengeTests
//
//  Created by AceGreen on 2025-02-18.
//

import XCTest
@testable import LeagueiOSChallenge

final class ModelTests: XCTestCase {
    func testUserModel() throws {
        let jsonData = """
        {
            "id": 1,
            "name": "Test User",
            "username": "testuser",
            "email": "test@example.com",
            "avatar": "https://example.com/avatar.jpg",
            "website": "example.com",
            "phone": "123-456-7890",
            "address": {
                "street": "Test St",
                "suite": "Apt 1",
                "city": "Test City",
                "zipcode": "12345",
                "geo": {
                    "lat": "12.34",
                    "lng": "56.78"
                }
            },
            "company": {
                "name": "Test Company",
                "catchPhrase": "Testing is good",
                "bs": "test bs"
            }
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let user = try decoder.decode(User.self, from: jsonData)
        
        XCTAssertEqual(user.id, 1)
        XCTAssertEqual(user.name, "Test User")
        XCTAssertEqual(user.username, "testuser")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.avatar, "https://example.com/avatar.jpg")
        XCTAssertTrue(user.isEmailValid)
    }
    
    func testPostModel() throws {
        let jsonData = """
        {
            "id": 1,
            "userId": 1,
            "title": "Test Post",
            "body": "This is a test post",
            "imageURL": "https://example.com/image.jpg"
        }
        """.data(using: .utf8)!
        
        let decoder = JSONDecoder()
        let post = try decoder.decode(Post.self, from: jsonData)
        
        XCTAssertEqual(post.id, 1)
        XCTAssertEqual(post.userId, 1)
        XCTAssertEqual(post.title, "Test Post")
        XCTAssertEqual(post.body, "This is a test post")
        XCTAssertEqual(post.imageURL, "https://example.com/image.jpg")
    }
    
    func testEmailValidation() {
        let validUser = User(
            id: 1,
            name: "Test",
            username: "test",
            email: "test@example.com",
            avatar: nil,
            website: nil,
            phone: nil,
            address: nil,
            company: nil
        )
        
        let invalidUser = User(
            id: 2,
            name: "Test",
            username: "test",
            email: "test@invalid",
            avatar: nil,
            website: nil,
            phone: nil,
            address: nil,
            company: nil
        )
        
        XCTAssertTrue(validUser.isEmailValid)
        XCTAssertFalse(invalidUser.isEmailValid)
    }
} 