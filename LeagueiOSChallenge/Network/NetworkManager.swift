//
//  NetworkManager.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

import Foundation
import SwiftUI

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

@Observable
final class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()

    var userType: User.UserType = .none
    var currentUser: User?
    var apiToken: String?

    private let apiHelper = APIHelper()
    private var userCache: [String: User] = [:]

    private init() {}

    @MainActor
    func login(username: String, password: String) async throws {
        print("Attempting to log in with username: \(username)")
        do {
            // Get API token
            let token = try await apiHelper.fetchUserToken(username: username, password: password)
            print("Received API token: \(token)")

            // Store token for future API calls
            self.apiToken = token

            // Fetch actual user profile
            self.currentUser = try await apiHelper.fetchUsers(tokens: [token]).first
            print("User logged in: \(self.currentUser?.username ?? "Unknown")")
            self.userType = .loggedIn

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

    @MainActor
    func fetchPosts() async throws -> [Post] {
        guard let token = apiToken else {
            throw NetworkError.unauthorized
        }

        return try await apiHelper.fetchPosts(token: token)
    }

    @MainActor
    func fetchUser(withId userId: Int) async throws -> User {
        // Convert userId to string since that's what the API expects
        let userIdString = String(userId)
        
        // Check cache first
        if let cachedUser = userCache[userIdString] {
            print("Returning cached user for ID: \(userId)")
            return cachedUser
        }
        
        guard let token = apiToken else {
            throw NetworkError.unauthorized
        }
        
        print("Fetching user with ID: \(userId)")
        let users = try await apiHelper.fetchUsers(tokens: [token])
        
        // Find the user with matching ID
        guard let user = users.first(where: { $0.id == userId }) else {
            throw NetworkError.networkError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
        }
        
        // Cache the user
        print("Caching user with ID: \(userId)")
        userCache[userIdString] = user
        return user
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
    }
}
