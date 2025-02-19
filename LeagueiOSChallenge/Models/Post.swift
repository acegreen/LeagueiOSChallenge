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
} 
