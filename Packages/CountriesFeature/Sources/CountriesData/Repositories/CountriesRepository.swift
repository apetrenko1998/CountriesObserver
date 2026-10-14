//
//  CountriesRepository.swift
//  CountriesData
//
//  Created by Anton Petrenko on 11/10/2026.
//

import CountriesAPI
import CountriesDomain
import Networking

/// Requests and response mapping are `@concurrent`, so they run off the main actor regardless of the package's
/// default isolation settings, even when called from a `@MainActor` view model.
public struct CountriesRepository: CountriesRepositoryInterface {
    private let client: any GraphQLClient

    public init(client: any GraphQLClient) {
        self.client = client
    }

    @concurrent
    public func countries(nameContaining: String?, forceRefresh: Bool) async throws -> [CountryEntity] {
        let filter: GraphQLNullable<CountryFilterInput> = nameContaining.map {
            .some(
                CountryFilterInput(
                    name: .some(
                        StringQueryOperatorInput(
                            regex: .some(
                                NameFilter.regex(for: $0)
                            )
                        )
                    )
                )
            )
        } ?? .none
        let data = try await fetch(CountriesQuery(filter: filter), policy: forceRefresh ? .networkOnly : .cacheFirst)
        return data.countries.map { CountryEntity(summary: $0.fragments.countrySummary) }
    }

    @concurrent
    public func countryDetails(code: String) async throws -> CountryDetailsEntity {
        let data = try await fetch(CountryDetailsQuery(code: code), policy: .cacheFirst)
        guard let country = data.country else {
            throw CountriesError.notFound
        }
        return CountryDetailsEntity(country)
    }

    private func fetch<Query: GraphQLQuery>(
        _ query: Query,
        policy: FetchPolicy
    ) async throws -> Query.Data where Query.ResponseFormat == SingleResponseFormat {
        do {
            return try await client.fetch(query, policy: policy)
        } catch let error as NetworkError {
            throw CountriesError(error)
        }
    }
}
