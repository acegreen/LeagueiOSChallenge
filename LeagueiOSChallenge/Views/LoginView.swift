//
//  APIHelper.swift
//  LeagueiOSChallenge
//
//  Copyright © 2024 League Inc. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.networkManager) private var networkManager
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var error: Error? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .textInputAutocapitalization(.never)
                .textContentType(UITextContentType.username)
                .accessibilityIdentifier("Username")
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
                .textContentType(UITextContentType.password)
                .accessibilityIdentifier("Password")
            
            Button("Login") {
                Task {
                    await login()
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading || username.isEmpty || password.isEmpty)
            .accessibilityIdentifier("Login")
            
            Button("Continue as guest") {
                Task {
                    await loginAsGuest()
                }
            }
            .disabled(isLoading)
            .accessibilityIdentifier("Continue as guest")
        }
        .padding()
        .errorAlert(error: $error)
    }
    
    private func login() async {
        guard !username.isEmpty && !password.isEmpty else {
            error = NetworkError.invalidInput("Username and password are required")
            return
        }
        
        do {
            isLoading = true
            try await networkManager.login(username: username, password: password)
        } catch {
            self.error = error
        }
        isLoading = false
    }
    
    private func loginAsGuest() async {
        isLoading = true
        do {
            try await networkManager.continueAsGuest()
        } catch {
            self.error = error
        }
        isLoading = false
    }
} 
