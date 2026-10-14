//
//  ErrorContent.swift
//  CountriesPresentation
//
//  Created by Anton Petrenko on 11/10/2026.
//

import CountriesDomain

struct ErrorContent: Equatable {
    let title: String
    let message: String
    let systemImage: String

    init(_ error: any Error) {
        switch error as? CountriesError {
        case .offline:
            title = "You're Offline"
            message = "Check your connection and try again."
            systemImage = "wifi.exclamationmark"
        case .notFound:
            title = "Country Not Found"
            message = "This country could not be found."
            systemImage = "questionmark.circle"
        case .server, .unknown, nil:
            title = "Something Went Wrong"
            message = "Please try again."
            systemImage = "exclamationmark.triangle"
        }
    }
}
