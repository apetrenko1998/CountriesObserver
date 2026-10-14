//
//  CountriesCoordinatorTests.swift
//  CountriesPresentationTests
//
//  Created by Anton Petrenko on 11/10/2026.
//

import CountriesDomain
@testable import CountriesPresentation
import DependencyInjection
import Testing

@MainActor
struct CountriesCoordinatorTests {
    private let germany = CountryEntity(id: "DE", name: "Germany", flag: "🇩🇪", continent: "Europe")
    private let japan = CountryEntity(id: "JP", name: "Japan", flag: "🇯🇵", continent: "Asia")

    /// Owned by the test: the coordinator only holds it weakly.
    private let container = DIContainer()

    private func makeCoordinator() -> CountriesCoordinator {
        container.register((any FetchCountriesUseCaseInterface).self) { _ in
            StubFetchCountries(result: .success([]))
        }
        container.register((any FetchCountryDetailsUseCaseInterface).self) { _ in
            StubFetchDetails(result: .failure(.unknown))
        }
        return CountriesCoordinator(resolver: container)
    }

    @Test func startsAtRoot() {
        #expect(makeCoordinator().path.isEmpty)
    }

    @Test func selectingCountryInListPushesDetails() {
        let coordinator = makeCoordinator()

        let viewModel = CountriesViewModel(
            fetchCountries: StubFetchCountries(result: .success([])),
            coordinator: coordinator
        )

        viewModel.select(germany)

        #expect(coordinator.path == [.details(germany)])
    }

    @Test func popRemovesTopScreen() {
        let coordinator = makeCoordinator()
        coordinator.showCountryDetails(germany)
        coordinator.showCountryDetails(japan)

        coordinator.pop()

        #expect(coordinator.path == [.details(germany)])
    }

    @Test func popToRootClearsStack() {
        let coordinator = makeCoordinator()
        coordinator.showCountryDetails(germany)
        coordinator.showCountryDetails(japan)

        coordinator.popToRoot()

        #expect(coordinator.path.isEmpty)
    }

    @Test func doesNotRetainResolver() throws {
        var container: DIContainer? = DIContainer()
        weak let weakContainer = container
        let coordinator = CountriesCoordinator(resolver: try #require(container))

        container = nil

        #expect(weakContainer == nil)
        _ = coordinator
    }

    @Test func showCountryDetailsPushesDetailsScreen() {
        let coordinator = makeCoordinator()

        coordinator.showCountryDetails(germany)

        #expect(coordinator.path == [.details(germany)])
    }

    @Test func rootViewResolvesListUseCase() {
        let coordinator = makeCoordinator()
        var resolutions = 0
        container.register((any FetchCountriesUseCaseInterface).self) { _ in
            resolutions += 1
            return StubFetchCountries(result: .success([]))
        }

        _ = coordinator.makeRootView()

        #expect(resolutions == 1)
    }

    @Test func detailsViewResolvesDetailsUseCase() {
        let coordinator = makeCoordinator()
        var resolutions = 0
        container.register((any FetchCountryDetailsUseCaseInterface).self) { _ in
            resolutions += 1
            return StubFetchDetails(result: .failure(.unknown))
        }

        _ = coordinator.makeView(for: .details(germany))

        #expect(resolutions == 1)
    }
}
