//
//  ErrorAlertModifier.swift
//  LeagueiOSChallenge
//
//  Created by AceGreen on 2025-02-18.
//

import SwiftUI

struct ErrorAlertModifier: ViewModifier {
    let error: Binding<Error?>
    let buttonTitle: String
    let action: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .alert(
                "Error",
                isPresented: .init(
                    get: { error.wrappedValue != nil },
                    set: { if !$0 { error.wrappedValue = nil } }
                ),
                presenting: error.wrappedValue,
                actions: { _ in
                    Button(buttonTitle) {
                        action?()
                    }
                },
                message: { error in
                    Text(error.localizedDescription)
                }
            )
    }
}

extension View {
    func errorAlert(
        error: Binding<Error?>,
        buttonTitle: String = "OK",
        action: (() -> Void)? = nil
    ) -> some View {
        modifier(ErrorAlertModifier(error: error, buttonTitle: buttonTitle, action: action))
    }
} 