//
//  ErrorStateModifier.swift
//  CountriesPresentation
//
//  Created by Anton Petrenko on 14/10/2026.
//

import SwiftUI

struct ErrorStateModifier: ViewModifier {
    let error: ErrorContent?
    let retry: @MainActor () async -> Void

    @ViewBuilder
    func body(content: Content) -> some View {
        if let error {
            ContentUnavailableView {
                Label(error.title, systemImage: error.systemImage)
            } description: {
                Text(error.message)
            } actions: {
                Button("Retry") {
                    Task { await retry() }
                }
            }
        } else {
            content
        }
    }
}

extension View {
    func errorState(_ error: ErrorContent?, retry: @escaping @MainActor () async -> Void) -> some View {
        modifier(ErrorStateModifier(error: error, retry: retry))
    }
}
