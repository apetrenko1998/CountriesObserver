//
//  GraphQLNetworkClient.swift
//  Networking
//
//  Created by Anton Petrenko on 11/10/2026.
//

import Apollo
import ApolloAPI
import Foundation

public final class GraphQLNetworkClient: GraphQLClient {
    private let client: ApolloClient

    public init(apolloClient: ApolloClient) {
        client = apolloClient
    }

    public convenience init(url: URL) {
        self.init(apolloClient: ApolloClient(url: url))
    }

    public func fetch<Query: GraphQLQuery>(
        _ query: Query,
        policy: FetchPolicy
    ) async throws -> Query.Data where Query.ResponseFormat == SingleResponseFormat {
        let response: GraphQLResponse<Query>
        do {
            response = try await client.fetch(query: query, cachePolicy: policy.apolloPolicy)
        } catch {
            if NetworkError.isCancellation(error) {
                throw CancellationError()
            }
            throw NetworkError(error)
        }
        return try data(from: response)
    }

    private func data<Query>(from response: GraphQLResponse<Query>) throws(NetworkError) -> Query.Data {
        if let data = response.data {
            return data
        }
        let messages = response.errors?.compactMap(\.message) ?? []
        throw messages.isEmpty ? .noData : .graphQL(messages: messages)
    }
}

private extension FetchPolicy {
    var apolloPolicy: CachePolicy.Query.SingleResponse {
        switch self {
        case .cacheFirst: .cacheFirst
        case .networkOnly: .networkOnly
        }
    }
}
