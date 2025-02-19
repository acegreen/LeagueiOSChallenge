//
//  Post.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

import Foundation

/// Represents a post in the system
/// Contains post content and other metadata
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
    
    /// String representation of the post's ID for Identifiable conformance
    var stringId: String { String(id) }
} 
