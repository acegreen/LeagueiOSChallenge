//
//  User.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

import Foundation

/// Represents a user in the system
/// Contains all user profile information and validation logic
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
    
    /// String representation of the user's ID for Identifiable conformance
    var stringId: String { String(id) }
    
    /// Avatar URL with fallback to placeholder if none provided
    var avatarURLString: String {
        avatar ?? "https://placehold.co/200x200"
    }

    /// Represents the authentication state of a user
    enum UserType {
        case none
        case guest
        case loggedIn
    }

    /// Validates the user's email domain
    /// - Returns: true if email ends with .com, .net, or .biz
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
