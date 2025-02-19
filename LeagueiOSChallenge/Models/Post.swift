//
//  Post.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

import Foundation

struct Post: Codable, Identifiable {
    let id: Int
    let userId: Int
    let title: String
    let body: String
    let imageURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case title
        case body
        case imageURL
    }
    
    // Conform to Identifiable with String ID
    var stringId: String { String(id) }
    
    // Instead of a computed property, let's make this a function
    // This avoids the 'noncopyable type' error
    func fetchUser() async throws -> User {
        return try await NetworkManager.shared.fetchUser(withId: userId)
    }
} 
