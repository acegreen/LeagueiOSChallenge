//
//  NetworkManager.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

import Foundation

enum APIError: Error {
    case invalidEndpoint
    case decodeFailure
    case unauthorized
}

enum APIEndpoint: String {
    case login = "login"
    case posts = "posts"
    case users = "users"

    func getURL(queryItems: [URLQueryItem]? = nil) -> URL? {
        let baseUrlString = "https://engineering.league.dev/challenge/api/"
        let urlString = "\(baseUrlString)\(rawValue)"
        
        guard var components = URLComponents(string: urlString) else {
            return nil
        }
        
        if let queryItems = queryItems {
            components.queryItems = queryItems
        }
        
        return components.url
    }
}

/// Handles direct API communication and request formatting
/// Responsible for:
/// - Constructing API requests
/// - Handling API responses
/// - Error translation
class APIHelper {
    /// Fetches an API token for authentication
    /// - Parameters:
    ///   - username: The user's username (empty for guest access)
    ///   - password: The user's password (empty for guest access)
    /// - Returns: API token string
    /// - Throws: APIError.invalidEndpoint if URL construction fails
    ///          APIError.unauthorized for invalid credentials
    ///          APIError.decodeFailure for invalid response format
    func fetchUserToken(username: String, password: String) async throws -> String {
        guard let url = APIEndpoint.login.getURL() else {
            print("Invalid endpoint URL")
            throw APIError.invalidEndpoint
        }

        let authString = "\(username):\(password)"
        let authData = Data(authString.utf8)
        let base64AuthString = "Basic \(authData.base64EncodedString())"
        let urlSessionConfig: URLSessionConfiguration = .default
        urlSessionConfig.httpAdditionalHeaders = ["Authorization": base64AuthString]
        let session = URLSession(configuration: urlSessionConfig)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        print("Sending login request to \(url)")
        let (data, response) = try await session.data(for: URLRequest(url: url))
        
        print("Received response: \(response)")
        
        if let results = try? decoder.decode(Login.self, from: data) {
            print("Decoded login response successfully")
            return results.apiKey
        } else {
            print("Failed to decode login response")
            throw APIError.decodeFailure
        }
    }
    
    /// Fetches posts from the API
    /// - Parameter token: Valid API token for authentication
    /// - Returns: Array of Post objects
    /// - Throws: APIError.invalidEndpoint if URL construction fails
    ///          APIError.unauthorized for invalid token
    ///          APIError.decodeFailure for invalid response format
    func fetchPosts(token: String, userId: Int? = nil) async throws -> [Post] {
        var queryItems: [URLQueryItem]? = nil
        if let userId = userId {
            queryItems = [URLQueryItem(name: "userId", value: String(userId))]
        }
        
        guard let url = APIEndpoint.posts.getURL(queryItems: queryItems) else {
            print("Invalid posts endpoint URL")
            throw APIError.invalidEndpoint
        }
        
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "x-access-token")
        
        print("Fetching posts from \(url)")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.decodeFailure
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        print("Received posts response: \(httpResponse)")
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let posts = try decoder.decode([Post].self, from: data)
            print("Successfully decoded \(posts.count) posts")
            return posts
        } catch {
            print("Failed to decode posts: \(error)")
            throw APIError.decodeFailure
        }
    }

    func fetchUsers(token: String) async throws -> [User] {
        guard let url = APIEndpoint.users.getURL() else {
            print("Invalid users endpoint URL")
            throw APIError.invalidEndpoint
        }
        
        var request = URLRequest(url: url)
        request.setValue(token, forHTTPHeaderField: "x-access-token")
        
        print("Fetching users from \(url)")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.decodeFailure
        }
        
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let users = try decoder.decode([User].self, from: data)
            print("Successfully decoded \(users.count) users")
            return users
        } catch {
            print("Failed to decode users: \(error)")
            throw APIError.decodeFailure
        }
    }
}
