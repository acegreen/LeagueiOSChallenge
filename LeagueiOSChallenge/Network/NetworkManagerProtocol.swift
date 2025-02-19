//
//  NetworkManagerProtocol.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

import SwiftUI
import Observation

protocol NetworkManagerProtocol: AnyObject {
    var userType: User.UserType { get set }
    var currentUser: User? { get set }
    var apiToken: String? { get set }
    
    func login(username: String, password: String) async throws
    func fetchPosts() async throws -> [Post]
    func fetchUser(withId userId: Int) async throws -> User
    func continueAsGuest() async throws
    func logout()
}
