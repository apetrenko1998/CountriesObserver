//
//  NetworkError.swift
//  Networking
//
//  Created by Anton Petrenko on 11/10/2026.
//

import Apollo
import Foundation

public enum NetworkError: Error, Equatable, Sendable {
    case offline
    case timeout
    case server(statusCode: Int)
    case graphQL(messages: [String])
    case noData
    case decoding
    case unknown(String)
}

extension NetworkError {
    /// URLSession reports a cancelled task as `URLError(.cancelled)`, not `CancellationError`.
    /// Treating it as a failure would show an error screen for a request nobody is waiting for.
    static func isCancellation(_ error: any Error) -> Bool {
        if error is CancellationError {
            return true
        }
        return (error as? URLError)?.code == .cancelled
    }

    init(_ error: any Error) {
        switch error {
        case let error as NetworkError:
            self = error
        case let error as URLError:
            self = Self(urlError: error)
        case let error as ResponseCodeInterceptor.ResponseCodeError:
            self = .server(statusCode: error.response.statusCode)
        case is JSONResponseParsingError, is GraphQLExecutionError:
            self = .decoding
        default:
            self = .unknown(String(describing: error))
        }
    }

    private init(urlError: URLError) {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            self = .offline
        case .timedOut:
            self = .timeout
        default:
            self = .unknown(urlError.localizedDescription)
        }
    }
}
