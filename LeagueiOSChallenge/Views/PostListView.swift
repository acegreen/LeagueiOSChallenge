//
//  PostListView.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

import SwiftUI

struct PostListView: View {
    @Environment(NetworkContainer.self) var networkContainer
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
                            PostRowView(post: post) { user in
                                selectedUser = user
                            }
                            .accessibilityIdentifier("PostCell")
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
                    Button(networkContainer.userType == .loggedIn ? "Logout" : "Exit") {
                        if networkContainer.userType == .guest {
                            showingThankYouAlert = true
                        } else {
                            networkContainer.logout()
                        }
                    }
                    .accessibilityIdentifier(networkContainer.userType == .loggedIn ? "Logout" : "Exit")
                }
            }
            .task {
                await loadPosts(userId: networkContainer.currentUser?.id)
            }
            .sheet(item: $selectedUser) { user in
                UserInformationView(user: user)
                    .accessibilityIdentifier("UserInfoView")
            }
            .alert("Thank You!", isPresented: $showingThankYouAlert) {
                Button("OK") {
                    networkContainer.logout()
                }
            } message: {
                Text("Thank you for trialing this app")
            }
            .errorAlert(error: $error)
        }
    }
    
    private func loadPosts(userId: Int? = nil) async {
        do {
            posts = try await networkContainer.fetchPosts(withId: userId)
        } catch {
            self.error = error
        }
    }
}

struct PostRowView: View {
    let post: Post
    @Environment(NetworkContainer.self) var networkContainer
    @State private var user: User?
    @State private var error: Error?
    let onUserTapped: (User) -> Void
    
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
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .onTapGesture {
                        onUserTapped(user)
                    }
                    
                    Text(user.username)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                        .accessibilityIdentifier("Username")
                } else {
                    ProgressView()
                        .frame(width: 48, height: 48)
                    Text("Loading...")
                        .foregroundColor(.secondary)
                }
            }
            .task {
                do {
                    user = try await networkContainer.fetchUser(withId: post.userId)
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
        .contentShape(Rectangle())
        .onTapGesture {
            if let user = user {
                onUserTapped(user)
            }
        }
    }
}
