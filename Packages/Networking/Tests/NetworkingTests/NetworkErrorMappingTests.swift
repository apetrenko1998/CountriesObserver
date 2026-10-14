//
//  NetworkErrorMappingTests.swift
//  NetworkingTests
//
//  Created by Anton Petrenko on 11/10/2026.
//

import Foundation
@testable import Networking
import Testing

struct NetworkErrorMappingTests {
    @Test(arguments: [URLError.Code.notConnectedToInternet, .networkConnectionLost, .dataNotAllowed])
    func connectivityErrorsMapToOffline(code: URLError.Code) {
        #expect(NetworkError(URLError(code)) == .offline)
    }

    @Test func timeoutMapsToTimeout() {
        #expect(NetworkError(URLError(.timedOut)) == .timeout)
    }

    @Test func cancelledRequestsAreCancellationNotFailure() {
        #expect(NetworkError.isCancellation(URLError(.cancelled)))
        #expect(NetworkError.isCancellation(CancellationError()))
        #expect(!NetworkError.isCancellation(URLError(.timedOut)))
    }

    @Test func networkErrorIsPassedThrough() {
        #expect(NetworkError(NetworkError.server(statusCode: 503)) == .server(statusCode: 503))
    }

    @Test func unrecognisedErrorMapsToUnknown() {
        struct SomeError: Error {}
        guard case .unknown = NetworkError(SomeError()) else {
            Issue.record("Expected .unknown")
            return
        }
    }
}
