//
//  CountryDetailsIntegrationTests.swift
//  CountriesIntegrationTests
//
//  Created by Anton Petrenko on 14/10/2026.
//

@testable import CountriesData
import CountriesDomain
@testable import CountriesPresentation
import Networking
import NetworkingTestSupport
import Testing

@MainActor
struct CountryDetailsIntegrationTests {
    private let country = CountryEntity(id: "DE", name: "Germany", flag: "🇩🇪", continent: "Europe")

    private func makeViewModel(client: MockGraphQLClient) -> CountryDetailsViewModel {
        CountryDetailsViewModel(
            country: country,
            fetchDetails: FetchCountryDetailsUseCase(repository: CountriesRepository(client: client))
        )
    }

    @Test func successfulResponseShowsMappedDetails() async {
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
        let viewModel = makeViewModel(client: client)

        await viewModel.load()

        #expect(viewModel.state == .loaded(CountryDetailsEntity(
            id: "DE",
            name: "Germany",
            flag: "🇩🇪",
            continent: "Europe",
            capital: "Berlin",
            currency: "EUR",
            languages: ["German"]
        )))
    }

    @Test func missingCountryShowsNotFoundError() async {
        let client = MockGraphQLClient { _ in CountryDetailsQuery.Data(country: nil) }
        let viewModel = makeViewModel(client: client)

        await viewModel.load()

        #expect(viewModel.state == .failed(ErrorContent(CountriesError.notFound)))
    }

    @Test func serverFailureShowsErrorState() async {
        let client = MockGraphQLClient { _ in throw NetworkError.server(statusCode: 500) }
        let viewModel = makeViewModel(client: client)

        await viewModel.load()

        #expect(viewModel.state == .failed(ErrorContent(CountriesError.server)))
    }
}
