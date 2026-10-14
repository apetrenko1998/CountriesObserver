//
//  CountryDetailsViewModelTests.swift
//  CountriesPresentationTests
//
//  Created by Anton Petrenko on 11/10/2026.
//

import CountriesDomain
@testable import CountriesPresentation
import Testing

@MainActor
struct CountryDetailsViewModelTests {
    private let country = CountryEntity(id: "DE", name: "Germany", flag: "🇩🇪", continent: "Europe")
    private let details = CountryDetailsEntity(
        id: "DE",
        name: "Germany",
        flag: "🇩🇪",
        continent: "Europe",
        capital: "Berlin",
        currency: "EUR",
        languages: ["German"]
    )

    private func makeViewModel(_ fetchDetails: StubFetchDetails) -> CountryDetailsViewModel {
        CountryDetailsViewModel(country: country, fetchDetails: fetchDetails)
    }

    @Test func startsInLoadingState() {
        let viewModel = makeViewModel(StubFetchDetails(result: .success(details)))

        #expect(viewModel.state == .loading)
    }

    @Test func successfulLoadShowsDetails() async {
        let viewModel = makeViewModel(StubFetchDetails(result: .success(details)))

        await viewModel.load()

        #expect(viewModel.state == .loaded(details))
    }

    @Test func requestsDetailsForTappedCountry() async {
        let stub = StubFetchDetails(result: .success(details))
        let viewModel = CountryDetailsViewModel(country: country, fetchDetails: stub)

        await viewModel.load()

        #expect(stub.requestedCodes == ["DE"])
    }

    @Test func networkFailureShowsUserFacingError() async {
        let viewModel = makeViewModel(StubFetchDetails(result: .failure(.offline)))

        await viewModel.load()

        #expect(viewModel.state == .failed(ErrorContent(CountriesError.offline)))
    }

    @Test func retryAfterFailureLoadsDetails() async {
        let stub = StubFetchDetails(result: .failure(.server))
        let viewModel = CountryDetailsViewModel(country: country, fetchDetails: stub)
        await viewModel.load()

        stub.result = .success(details)
        await viewModel.load()

        #expect(viewModel.state == .loaded(details))
    }
}
