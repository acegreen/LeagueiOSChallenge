//
//  NetworkManager.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

import Foundation
import SwiftUI
import Observation

enum NetworkError: LocalizedError {
    case invalidCredentials
    case networkError(Error)
    case unauthorized
    case invalidInput(String)
    case decodingError(String)
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid username or password"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized access. Please login again."
        case .invalidInput(let message):
            return "Invalid Input: \(message)"
        case .decodingError(let message):
            return "Data Error: \(message)"
        case .serverError(let message):
            return "Server Error: \(message)"
        }
    }
}

/// Manages all network operations and authentication state for the application
/// Responsible for:
/// - User authentication (login, guest access, logout)
/// - API token management
/// - User session state
/// - Network requests caching
@Observable class NetworkManager: NetworkManagerProtocol {
    var userType: User.UserType = .none
    var currentUser: User?
    var apiToken: String?

    private let apiHelper: APIHelper
    private let cacheManager: CacheManager

    init(apiHelper: APIHelper = APIHelper(), cacheManager: CacheManager) {
        self.apiHelper = apiHelper
        self.cacheManager = cacheManager
    }

    /// Attempts to authenticate a user with provided credentials
    /// - Parameters:
    ///   - username: The user's username
    ///   - password: The user's password
    /// - Throws: NetworkError.invalidCredentials if authentication fails
    ///          NetworkError.networkError for other failures
    /// - Note: On successful login, updates userType to .loggedIn and stores the API token
    @MainActor
    func login(username: String, password: String) async throws {
        print("Attempting to log in with username: \(username)")
        do {
            // Get API token
            let token = try await apiHelper.fetchUserToken(username: username, password: password)
            print("Received API token: \(token)")

            // Store token for future API calls
            self.apiToken = token

            // Load all users into cache
            try await loadAllUsers()
            
            // Find matching user from cache (case-insensitive)
            if let matchingUser = cacheManager.getUser(withUsername: username) {
                self.currentUser = matchingUser
                print("User logged in: \(self.currentUser?.username ?? "Unknown")")
                self.userType = .loggedIn
            } else {
                throw NetworkError.invalidInput("User not found")
            }

        } catch APIError.invalidEndpoint {
            throw NetworkError.networkError(APIError.invalidEndpoint)
        } catch APIError.unauthorized {
            throw NetworkError.invalidCredentials
        } catch APIError.decodeFailure {
            throw NetworkError.networkError(APIError.decodeFailure)
        } catch {
            throw NetworkError.networkError(error)
        }
    }

    /// Fetches all posts from the API
    /// - Returns: Array of Post objects
    /// - Throws: NetworkError.unauthorized if no valid token exists
    ///          NetworkError.networkError for other failures
    /// - Note: Requires a valid API token
    @MainActor
    func fetchPosts(withId userId: Int? = nil) async throws -> [Post] {
        guard let token = apiToken else {
            throw NetworkError.unauthorized
        }

        return try await apiHelper.fetchPosts(token: token, userId: userId)
    }

    /// Fetches all users and caches them for future use
    @MainActor
    internal func loadAllUsers() async throws {
        guard !cacheManager.isUsersCached, let token = apiToken else {
            if apiToken == nil {
                throw NetworkError.unauthorized
            }
            return
        }
        
        print("Fetching all users")
        let users = try await apiHelper.fetchUsers(token: token)
        cacheManager.cacheUsers(users)
    }

    /// Fetches a specific user by their ID, using cache when available
    /// - Parameter userId: The unique identifier of the user
    /// - Returns: User object matching the provided ID
    /// - Throws: NetworkError.unauthorized if no valid token exists
    ///          NetworkError.networkError if user not found or other failures
    @MainActor
    func fetchUser(withId userId: Int) async throws -> User {
        // Check cache first
        if let cachedUser = cacheManager.getUser(withId: userId) {
            print("Returning cached user for ID: \(userId)")
            return cachedUser
        }
        
        throw NetworkError.networkError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
    }

    @MainActor
    func continueAsGuest() async throws {
        print("Continuing as guest")
        do {
            // Get API token without credentials
            let token = try await apiHelper.fetchUserToken(username: "", password: "")
            print("Received guest token: \(token)")
            
            // Store token for future API calls
            self.apiToken = token
            
            // Load all users into cache
            try await loadAllUsers()
            
            self.userType = .guest
            self.currentUser = nil
            
        } catch {
            print("Failed to get guest token: \(error)")
            throw NetworkError.networkError(error)
        }
    }

    func logout() {
        print("Logging out")
        userType = .none
        currentUser = nil
        apiToken = nil
        cacheManager.clearCache()
    }
}
