//
//  User.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let name: String
    let username: String
    let email: String
    let avatar: String?
    let website: String?
    let phone: String?
    let address: Address?
    let company: Company?
    
    // Conform to Identifiable with String ID
    var stringId: String { String(id) }
    
    // Computed property for avatar URL with fallback
    var avatarURLString: String {
        avatar ?? "https://placekitten.com/200/200"
    }

    enum UserType {
        case none
        case guest
        case loggedIn
    }

    var isEmailValid: Bool {
        let validDomains = [".com", ".net", ".biz"]
        return validDomains.contains { email.hasSuffix($0) }
    }
    
    struct Address: Codable {
        let street: String
        let suite: String
        let city: String
        let zipcode: String
        let geo: Geo
        
        struct Geo: Codable {
            let lat: String
            let lng: String
        }
    }
    
    struct Company: Codable {
        let name: String
        let catchPhrase: String
        let bs: String
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, username, email, avatar, website, phone, address, company
    }
} 
