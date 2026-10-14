//
//  CountriesListIntegrationTests.swift
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
struct CountriesListIntegrationTests {
    private let coordinator = NoOpCoordinator()

    private func makeViewModel(client: MockGraphQLClient) -> CountriesViewModel {
        let repository = CountriesRepository(client: client)
        return CountriesViewModel(
            fetchCountries: FetchCountriesUseCase(repository: repository),
            coordinator: coordinator
        )
    }

    @Test func successfulResponseShowsMappedCountries() async {
        let client = MockGraphQLClient { _ in
            CountriesQuery.Data(countries: [
                .init(code: "DE", name: "Germany", emoji: "🇩🇪", continent: .init(name: "Europe")),
                .init(code: "JP", name: "Japan", emoji: "🇯🇵", continent: .init(name: "Asia"))
            ])
        }
        let viewModel = makeViewModel(client: client)

        await viewModel.load()

        #expect(viewModel.state == .loaded([
            CountryEntity(id: "DE", name: "Germany", flag: "🇩🇪", continent: "Europe"),
            CountryEntity(id: "JP", name: "Japan", flag: "🇯🇵", continent: "Asia")
        ]))
        #expect(client.requests.count == 1)
    }

    @Test func emptyResponseShowsEmptyState() async {
        let client = MockGraphQLClient { _ in CountriesQuery.Data(countries: []) }
        let viewModel = makeViewModel(client: client)
        viewModel.searchText = "zzz"

        await viewModel.load()

        #expect(viewModel.state == .empty(query: "zzz"))
    }

    @Test func networkFailureShowsErrorState() async {
        let client = MockGraphQLClient { _ in throw NetworkError.offline }
        let viewModel = makeViewModel(client: client)

        await viewModel.load()

        #expect(viewModel.state == .failed(ErrorContent(CountriesError.offline)))
    }
}

@MainActor
private final class NoOpCoordinator: CountriesCoordinating {
    func showCountryDetails(_ country: CountryEntity) {}
}
