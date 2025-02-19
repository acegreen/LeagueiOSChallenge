//
//  NetworkManagerProtocol.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

import Foundation
import SwiftUI

protocol NetworkManagerProtocol: Observable {
    var userType: User.UserType { get set }
    var currentUser: User? { get set }
    
    func login(username: String, password: String) async throws
    func continueAsGuest() async throws
    func fetchPosts() async throws -> [Post]
    func fetchUser(withId: Int) async throws -> User
    func logout()
}

private struct NetworkManagerKey: EnvironmentKey {
    static let defaultValue: NetworkManagerProtocol = NetworkManager.shared
}

extension EnvironmentValues {
    var networkManager: NetworkManagerProtocol {
        get { self[NetworkManagerKey.self] }
        set { self[NetworkManagerKey.self] = newValue }
    }
} 