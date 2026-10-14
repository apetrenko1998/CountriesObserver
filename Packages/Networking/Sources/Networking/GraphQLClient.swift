//
//  GraphQLClient.swift
//  Networking
//
//  Created by Anton Petrenko on 11/10/2026.
//

import ApolloAPI

public protocol GraphQLClient: Sendable {
    func fetch<Query: GraphQLQuery>(
        _ query: Query,
        policy: FetchPolicy
    ) async throws -> Query.Data where Query.ResponseFormat == SingleResponseFormat
}
