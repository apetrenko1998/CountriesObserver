//
//  CountriesRepositoryTests.swift
//  CountriesDataTests
//
//  Created by Anton Petrenko on 11/10/2026.
//

@testable import CountriesData
import CountriesDomain
import Networking
import NetworkingTestSupport
import Testing

struct CountriesRepositoryTests {
    @Test func missingCountryThrowsNotFound() async {
        let repository = CountriesRepository(client: MockGraphQLClient { _ in CountryDetailsQuery.Data(country: nil) })

        await #expect(throws: CountriesError.notFound) {
            try await repository.countryDetails(code: "XX")
        }
    }

    @Test(arguments: [
        (NetworkError.offline, CountriesError.offline),
        (.timeout, .offline),
        (.server(statusCode: 500), .server),
        (.graphQL(messages: ["boom"]), .server),
        (.noData, .server),
        (.decoding, .server),
        (.unknown("?"), .unknown)
    ])
    func networkErrorsMapToDomainErrors(networkError: NetworkError, expected: CountriesError) async {
        let repository = CountriesRepository(client: MockGraphQLClient { _ in throw networkError })

        await #expect(throws: expected) {
            try await repository.countries(nameContaining: nil, forceRefresh: false)
        }
    }

    @Test func cancellationIsPassedThrough() async {
        let repository = CountriesRepository(client: MockGraphQLClient { _ in throw CancellationError() })

        await #expect(throws: CancellationError.self) {
            try await repository.countries(nameContaining: nil, forceRefresh: false)
        }
    }

    @Test(arguments: [(false, FetchPolicy.cacheFirst), (true, .networkOnly)])
    func forceRefreshSelectsFetchPolicy(forceRefresh: Bool, expected: FetchPolicy) async throws {
        let client = MockGraphQLClient { _ in CountriesQuery.Data(countries: []) }

        _ = try await CountriesRepository(client: client).countries(nameContaining: nil, forceRefresh: forceRefresh)

        #expect(client.requests.map(\.policy) == [expected])
    }

    @Test func nameFilterIsSentAsCaseInsensitiveRegex() async throws {
        let client = MockGraphQLClient { _ in CountriesQuery.Data(countries: []) }

        _ = try await CountriesRepository(client: client).countries(nameContaining: "ger", forceRefresh: false)

        let query = try #require(client.requests.first?.query as? CountriesQuery)
        #expect(query.filter.unwrapped?.name.unwrapped?.regex.unwrapped == "[gG][eE][rR]")
    }

    @Test func emptyFilterIsOmitted() async throws {
        let client = MockGraphQLClient { _ in CountriesQuery.Data(countries: []) }

        _ = try await CountriesRepository(client: client).countries(nameContaining: nil, forceRefresh: false)

        let query = try #require(client.requests.first?.query as? CountriesQuery)
        #expect(query.filter == .none)
    }

    // MARK: - Countries

    @Test func emptyCountriesResponseMapsToEmptyList() async throws {
        let repository = CountriesRepository(client: MockGraphQLClient { _ in CountriesQuery.Data(countries: []) })

        let countries = try await repository.countries(nameContaining: nil, forceRefresh: false)

        #expect(countries.isEmpty)
    }

    @Test func countriesResponseKeepsServerOrder() async throws {
        let client = MockGraphQLClient { _ in
            CountriesQuery.Data(countries: [
                .init(code: "JP", name: "Japan", emoji: "🇯🇵", continent: .init(name: "Asia")),
                .init(code: "AD", name: "Andorra", emoji: "🇦🇩", continent: .init(name: "Europe")),
                .init(code: "DE", name: "Germany", emoji: "🇩🇪", continent: .init(name: "Europe"))
            ])
        }

        let countries = try await CountriesRepository(client: client).countries(nameContaining: "a", forceRefresh: true)

        #expect(countries.map(\.id) == ["JP", "AD", "DE"])
    }

    @Test func countriesSendsSingleCountriesQuery() async throws {
        let client = MockGraphQLClient { _ in CountriesQuery.Data(countries: []) }

        _ = try await CountriesRepository(client: client).countries(nameContaining: "ger", forceRefresh: false)

        #expect(client.requests.count == 1)
        #expect(client.requests.first?.query is CountriesQuery)
    }

    // MARK: - Country details

    @Test func detailsSendsRequestedCode() async throws {
        let client = MockGraphQLClient { _ in CountryDetailsQuery.Data(country: .germany) }

        _ = try await CountriesRepository(client: client).countryDetails(code: "DE")

        let query = try #require(client.requests.first?.query as? CountryDetailsQuery)
        #expect(query.code == "DE")
        #expect(client.requests.count == 1)
    }

    @Test func detailsUsesCacheFirstPolicy() async throws {
        let client = MockGraphQLClient { _ in CountryDetailsQuery.Data(country: .germany) }

        _ = try await CountriesRepository(client: client).countryDetails(code: "DE")

        #expect(client.requests.map(\.policy) == [.cacheFirst])
    }

    @Test func detailsKeepsLanguagesOrder() async throws {
        let client = MockGraphQLClient { _ in
            CountryDetailsQuery.Data(country: .init(
                capital: "Bern",
                currency: "CHF",
                languages: [.init(name: "German"), .init(name: "French"), .init(name: "Italian")],
                code: "CH",
                name: "Switzerland",
                emoji: "🇨🇭",
                continent: .init(name: "Europe")
            ))
        }

        let details = try await CountriesRepository(client: client).countryDetails(code: "CH")

        #expect(details.languages == ["German", "French", "Italian"])
    }

    @Test(arguments: [
        (NetworkError.offline, CountriesError.offline),
        (.timeout, .offline),
        (.server(statusCode: 503), .server),
        (.graphQL(messages: ["boom"]), .server),
        (.noData, .server),
        (.decoding, .server),
        (.unknown("?"), .unknown)
    ])
    func detailsNetworkErrorsMapToDomainErrors(networkError: NetworkError, expected: CountriesError) async {
        let repository = CountriesRepository(client: MockGraphQLClient { _ in throw networkError })

        await #expect(throws: expected) {
            try await repository.countryDetails(code: "DE")
        }
    }

    @Test func detailsCancellationIsPassedThrough() async {
        let repository = CountriesRepository(client: MockGraphQLClient { _ in throw CancellationError() })

        await #expect(throws: CancellationError.self) {
            try await repository.countryDetails(code: "DE")
        }
    }
}

private extension CountryDetailsQuery.Data.Country {
    static let germany = Self(
        capital: "Berlin",
        currency: "EUR",
        languages: [.init(name: "German")],
        code: "DE",
        name: "Germany",
        emoji: "🇩🇪",
        continent: .init(name: "Europe")
    )
}
