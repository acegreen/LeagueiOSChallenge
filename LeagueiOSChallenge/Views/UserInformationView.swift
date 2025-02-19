//
//  UserInformationView.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

import SwiftUI

struct UserInformationView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    AsyncImage(url: URL(string: user.avatarURLString)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .accessibilityIdentifier("Avatar")
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())

                    Text(user.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .accessibilityIdentifier("Username")

                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(title: "Username", value: user.username)
                        InfoRow(title: "Email", value: user.email, showWarning: !user.isEmailValid)
                        if let phone = user.phone {
                            InfoRow(title: "Phone", value: phone)
                        }
                        if let website = user.website {
                            InfoRow(title: "Website", value: website)
                        }
                        if let address = user.address {
                            InfoRow(title: "Address", value: "\(address.street), \(address.suite)\n\(address.city) \(address.zipcode)")
                        }
                        if let company = user.company {
                            InfoRow(title: "Company", value: company.name)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
            .navigationTitle("User Information")
            .accessibilityIdentifier("UserInfoView")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityIdentifier("Done")
                }
            }
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    var showWarning: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                Text(value)
                    .font(.body)
                if showWarning {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                        .accessibilityLabel("Warning")
                        .accessibilityIdentifier("EmailWarningIcon")
                }
            }
        }
        .accessibilityIdentifier("InfoRow")
    }
}

