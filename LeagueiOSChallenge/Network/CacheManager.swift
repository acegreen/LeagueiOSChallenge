import Foundation
import Observation

class CacheManager {
    private var userCache: [String: User] = [:]
    private var hasLoadedAllUsers = false
    
    func cacheUsers(_ users: [User]) {
        for user in users {
            userCache[String(user.id)] = user
        }
        hasLoadedAllUsers = true
        print("Cached \(users.count) users")
    }
    
    func getUser(withId userId: Int) -> User? {
        let userIdString = String(userId)
        return userCache[userIdString]
    }
    
    func getUser(withUsername username: String) -> User? {
        return userCache.values.first { $0.username.lowercased() == username.lowercased() }
    }
    
    func clearCache() {
        userCache.removeAll()
        hasLoadedAllUsers = false
    }
    
    var isUsersCached: Bool {
        hasLoadedAllUsers
    }
} 
