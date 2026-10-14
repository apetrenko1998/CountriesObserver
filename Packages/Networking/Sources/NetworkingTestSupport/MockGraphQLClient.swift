//
//  MockGraphQLClient.swift
//  NetworkingTestSupport
//
//  Created by Anton Petrenko on 11/10/2026.
//

import ApolloAPI
import Foundation
import Networking

/// Returns canned data for queries and records how it was called. Never touches the network.
public final class MockGraphQLClient: GraphQLClient, @unchecked Sendable {
    public typealias Request = (query: any GraphQLOperation, policy: FetchPolicy)

    private let lock = NSLock()
    private let handler: @Sendable (any GraphQLOperation) throws -> any Sendable
    private var recordedRequests: [Request] = []

    public init(handler: @escaping @Sendable (any GraphQLOperation) throws -> any Sendable) {
        self.handler = handler
    }

    public var requests: [Request] {
        lock.withLock { recordedRequests }
    }

    public func fetch<Query: GraphQLQuery>(
        _ query: Query,
        policy: FetchPolicy
    ) async throws -> Query.Data where Query.ResponseFormat == SingleResponseFormat {
        lock.withLock { recordedRequests.append((query, policy)) }
        guard let data = try handler(query) as? Query.Data else {
            fatalError("MockGraphQLClient: handler returned wrong data type for \(Query.self)")
        }
        return data
    }
}
