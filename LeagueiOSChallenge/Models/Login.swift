//
//  Login.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

import Foundation

/// Represents the response from a successful login attempt
/// Contains the API key needed for authenticated requests
struct Login: Codable {
    /// The API key returned from a successful authentication
    /// Used as a bearer token for subsequent API requests
    let apiKey: String
}
