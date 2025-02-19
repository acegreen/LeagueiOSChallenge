//
//  PostListView.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

import SwiftUI

struct PostListView: View {
    @Environment(NetworkManager.self) private var networkManager
    @State private var posts: [Post] = []
    @State private var selectedUser: User?
    @State private var error: Error? = nil
    @State private var showingThankYouAlert = false

    var body: some View {
        NavigationView {
            Group {
                if !posts.isEmpty {
                    List {
                        ForEach(posts) { post in
                            PostRowView(post: post)
                                .contentShape(Rectangle())
                                .accessibilityIdentifier("PostCell")
                                .onTapGesture {
                                    Task {
                                        do {
                                            let user = try await networkManager.fetchUser(withId: post.userId)
                                            selectedUser = user
                                        } catch {
                                            self.error = error
                                        }
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                    .accessibilityIdentifier("PostsList")
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Posts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(networkManager.userType == .loggedIn ? "Logout" : "Exit") {
                        if networkManager.userType == .guest {
                            showingThankYouAlert = true
                        } else {
                            networkManager.logout()
                        }
                    }
                    .accessibilityIdentifier(networkManager.userType == .loggedIn ? "Logout" : "Exit")
                }
            }
            .task {
                await loadPosts()
            }
            .sheet(item: $selectedUser) { user in
                UserInformationView(user: user)
                    .accessibilityIdentifier("UserInfoView")
            }
            .alert("Thank You!", isPresented: $showingThankYouAlert) {
                Button("OK") {
                    networkManager.logout()
                }
            } message: {
                Text("Thank you for trialing this app")
            }
            .errorAlert(error: $error)
        }
    }
    
    private func loadPosts() async {
        do {
            posts = try await networkManager.fetchPosts()
        } catch {
            self.error = error
        }
    }
}

struct PostRowView: View {
    let post: Post
    @Environment(NetworkManager.self) private var networkManager
    @State private var user: User?
    @State private var error: Error?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let user = user {
                    AsyncImage(url: URL(string: user.avatarURLString)) { image in
                        image
                            .resizable()
                            .accessibilityIdentifier("Avatar")
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    
                    Text(user.username)
                        .fontWeight(.bold)
                        .accessibilityIdentifier("Username")
                } else {
                    ProgressView()
                        .frame(width: 40, height: 40)
                    Text("Loading...")
                        .foregroundColor(.secondary)
                }
            }
            .task {
                do {
                    user = try await networkManager.fetchUser(withId: post.userId)
                } catch {
                    self.error = error
                }
            }
            
            Text(post.title)
                .font(.headline)
            
            Text(post.body)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .errorAlert(error: $error)
        .accessibilityIdentifier("PostRow")
    }
}
