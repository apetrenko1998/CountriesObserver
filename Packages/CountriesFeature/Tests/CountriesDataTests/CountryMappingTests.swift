//
//  CountryMappingTests.swift
//  CountriesDataTests
//
//  Created by Anton Petrenko on 11/10/2026.
//

@testable import CountriesData
import CountriesDomain
import NetworkingTestSupport
import Testing

struct CountryMappingTests {
    @Test func countriesResponseMapsToDomainModels() async throws {
        let client = MockGraphQLClient { _ in
            CountriesQuery.Data(countries: [
                .init(code: "DE", name: "Germany", emoji: "🇩🇪", continent: .init(name: "Europe")),
                .init(code: "JP", name: "Japan", emoji: "🇯🇵", continent: .init(name: "Asia"))
            ])
        }
        let repository = CountriesRepository(client: client)

        let countries = try await repository.countries(nameContaining: nil, forceRefresh: false)

        #expect(countries == [
            CountryEntity(id: "DE", name: "Germany", flag: "🇩🇪", continent: "Europe"),
            CountryEntity(id: "JP", name: "Japan", flag: "🇯🇵", continent: "Asia")
        ])
    }

    @Test func detailsResponseMapsToDomainModel() async throws {
        let client = MockGraphQLClient { _ in
            CountryDetailsQuery.Data(country: .init(
                capital: "Berlin",
                currency: "EUR",
                languages: [.init(name: "German")],
                code: "DE",
                name: "Germany",
                emoji: "🇩🇪",
                continent: .init(name: "Europe")
            ))
        }
        let repository = CountriesRepository(client: client)

        let details = try await repository.countryDetails(code: "DE")

        #expect(details == CountryDetailsEntity(
            id: "DE",
            name: "Germany",
            flag: "🇩🇪",
            continent: "Europe",
            capital: "Berlin",
            currency: "EUR",
            languages: ["German"]
        ))
    }

    @Test func missingOptionalFieldsMapToNil() async throws {
        let client = MockGraphQLClient { _ in
            CountryDetailsQuery.Data(country: .init(
                languages: [],
                code: "AQ",
                name: "Antarctica",
                emoji: "🇦🇶",
                continent: .init(name: "Antarctica")
            ))
        }
        let details = try await CountriesRepository(client: client).countryDetails(code: "AQ")

        #expect(details.capital == nil)
        #expect(details.currency == nil)
        #expect(details.languages.isEmpty)
    }
}
