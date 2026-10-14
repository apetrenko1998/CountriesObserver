//
//  CountriesViewModelTests.swift
//  CountriesPresentationTests
//
//  Created by Anton Petrenko on 11/10/2026.
//

import CountriesDomain
@testable import CountriesPresentation
import Testing

@MainActor
struct CountriesViewModelTests {
    private let germany = CountryEntity(id: "DE", name: "Germany", flag: "🇩🇪", continent: "Europe")
    private let japan = CountryEntity(id: "JP", name: "Japan", flag: "🇯🇵", continent: "Asia")

    /// Owned by the test: the view model only holds it weakly.
    private let coordinator = CoordinatorSpy()

    private func makeViewModel(_ fetch: any FetchCountriesUseCaseInterface) -> CountriesViewModel {
        CountriesViewModel(
            fetchCountries: fetch,
            coordinator: coordinator,
            debounceInterval: .milliseconds(20)
        )
    }

    @Test func rewritingSameSearchTextDoesNotReload() async throws {
        let fetch = StubFetchCountries(result: .success([germany]))
        let viewModel = makeViewModel(fetch)
        await viewModel.loadIfNeeded()

        viewModel.searchText = ""
        try await Task.sleep(for: .milliseconds(100))

        #expect(fetch.calls.count == 1)
        #expect(viewModel.state == .loaded([germany]))
    }

    @Test func cancelledLoadRestoresPreviousState() async {
        let fetch = StubFetchCountries(result: .success([germany]))
        let viewModel = makeViewModel(fetch)
        await viewModel.load()

        fetch.thrownError = CancellationError()
        await viewModel.load(forceRefresh: true)

        #expect(viewModel.state == .loaded([germany]))
    }

    @Test func cancelledInitialLoadIsRetriedOnNextAppearance() async {
        let fetch = StubFetchCountries(result: .success([germany]))
        fetch.thrownError = CancellationError()
        let viewModel = makeViewModel(fetch)
        await viewModel.loadIfNeeded()

        fetch.thrownError = nil
        await viewModel.loadIfNeeded()

        #expect(fetch.calls.count == 2)
        #expect(viewModel.state == .loaded([germany]))
    }

    @Test func staleResponseDoesNotOverrideNewerSearch() async throws {
        let germany = germany
        let japan = japan
        let fetch = ScriptedFetchCountries { query in
            query == "ge" ? (.milliseconds(300), [germany]) : (.zero, [japan])
        }
        let viewModel = makeViewModel(fetch)

        viewModel.searchText = "ge"
        try await Task.sleep(for: .milliseconds(60))
        viewModel.searchText = "ja"
        try await waitUntil { viewModel.state == .loaded([japan]) }
        // Let the slow "ge" response arrive.
        try await Task.sleep(for: .milliseconds(400))

        #expect(viewModel.state == .loaded([japan]))
    }

    @Test func initialLoadHappensOnlyOnce() async {
        let fetch = StubFetchCountries(result: .success([germany]))
        let viewModel = makeViewModel(fetch)

        await viewModel.loadIfNeeded()
        await viewModel.loadIfNeeded()

        #expect(fetch.calls.count == 1)
    }

    @Test func selectingCountryAsksCoordinatorToShowDetails() {
        let viewModel = makeViewModel(StubFetchCountries(result: .success([])))

        viewModel.select(germany)

        #expect(coordinator.shownDetails == [germany])
    }

    @Test func successfulLoadShowsCountries() async {
        let viewModel = makeViewModel(StubFetchCountries(result: .success([germany, japan])))

        await viewModel.load()

        #expect(viewModel.state == .loaded([germany, japan]))
    }

    @Test func emptyResultShowsEmptyState() async {
        let viewModel = makeViewModel(StubFetchCountries(result: .success([])))
        viewModel.searchText = "zzz"

        await viewModel.load()

        #expect(viewModel.state == .empty(query: "zzz"))
    }

    @Test func networkFailureShowsUserFacingError() async {
        let viewModel = makeViewModel(StubFetchCountries(result: .failure(.offline)))

        await viewModel.load()

        #expect(viewModel.state == .failed(ErrorContent(CountriesError.offline)))
    }

    @Test func retryAfterFailureShowsCountries() async {
        let fetch = StubFetchCountries(result: .failure(.server))
        let viewModel = makeViewModel(fetch)
        await viewModel.load()

        fetch.result = .success([germany])
        await viewModel.load()

        #expect(viewModel.state == .loaded([germany]))
    }

    @Test func pullToRefreshBypassesCache() async {
        let fetch = StubFetchCountries(result: .success([germany]))
        let viewModel = makeViewModel(fetch)

        await viewModel.load(forceRefresh: true)

        #expect(fetch.calls == [.init(query: "", forceRefresh: true)])
    }

    @Test func typingIsDebouncedIntoSingleRequest() async throws {
        let fetch = StubFetchCountries(result: .success([germany]))
        let viewModel = makeViewModel(fetch)

        viewModel.searchText = "g"
        viewModel.searchText = "ge"
        viewModel.searchText = "ger"
        try await waitUntil { viewModel.state == .loaded([germany]) }
        // Give any extra (incorrect) emissions a chance to arrive.
        try await Task.sleep(for: .milliseconds(100))

        #expect(fetch.calls == [.init(query: "ger", forceRefresh: false)])
    }

    @Test func whitespaceOnlyChangeDoesNotTriggerNewRequest() async throws {
        let fetch = StubFetchCountries(result: .success([germany]))
        let viewModel = makeViewModel(fetch)

        viewModel.searchText = "ger"
        try await waitUntil { fetch.calls.count == 1 }
        viewModel.searchText = "ger "
        try await Task.sleep(for: .milliseconds(100))

        #expect(fetch.calls.count == 1)
    }

    @Test func typingAndErasingWithinDebounceDoesNotReload() async throws {
        let fetch = StubFetchCountries(result: .success([germany]))
        let viewModel = makeViewModel(fetch)
        await viewModel.loadIfNeeded()

        viewModel.searchText = "g"
        viewModel.searchText = ""
        try await Task.sleep(for: .milliseconds(100))

        #expect(fetch.calls.count == 1)
    }

    @Test func returningToLastIssuedQueryDoesNotReload() async throws {
        let fetch = StubFetchCountries(result: .success([germany]))
        let viewModel = makeViewModel(fetch)

        viewModel.searchText = "ger"
        try await waitUntil { fetch.calls.count == 1 }
        viewModel.searchText = "germ"
        viewModel.searchText = "ger"
        try await Task.sleep(for: .milliseconds(100))

        #expect(fetch.calls.count == 1)
    }

    @Test func searchOverLoadedResultsKeepsThemAndShowsIndicator() async throws {
        let germany = germany
        let japan = japan
        let fetch = ScriptedFetchCountries { query in
            query.isEmpty ? (.zero, [germany]) : (.milliseconds(200), [japan])
        }
        let viewModel = makeViewModel(fetch)
        await viewModel.load()

        viewModel.searchText = "ja"
        try await waitUntil { viewModel.isSearching }
        #expect(viewModel.state == .loaded([germany]))

        try await waitUntil { viewModel.state == .loaded([japan]) }
        #expect(!viewModel.isSearching)
    }

    @Test func pullToRefreshDoesNotShowSearchIndicator() async throws {
        let germany = germany
        let fetch = ScriptedFetchCountries { _ in (.milliseconds(100), [germany]) }
        let viewModel = makeViewModel(fetch)
        await viewModel.load()

        let refresh = Task { await viewModel.load(forceRefresh: true) }
        try await Task.sleep(for: .milliseconds(30))
        #expect(!viewModel.isSearching)
        await refresh.value
    }

    @Test func failedSearchClearsIndicator() async {
        let fetch = StubFetchCountries(result: .success([germany]))
        let viewModel = makeViewModel(fetch)
        await viewModel.load()

        fetch.result = .failure(.offline)
        await viewModel.load()

        #expect(!viewModel.isSearching)
        #expect(viewModel.state == .failed(ErrorContent(CountriesError.offline)))
    }

    @Test func searchWithNoMatchesShowsEmptyState() async throws {
        let fetch = StubFetchCountries(result: .success([]))
        let viewModel = makeViewModel(fetch)

        viewModel.searchText = "xyz"
        try await waitUntil { viewModel.state == .empty(query: "xyz") }
    }
}

@MainActor
func waitUntil(
    timeout: Duration = .seconds(2),
    _ condition: @MainActor () -> Bool,
    sourceLocation: SourceLocation = #_sourceLocation
) async throws {
    let deadline = ContinuousClock.now + timeout
    while !condition() {
        guard ContinuousClock.now < deadline else {
            Issue.record("Condition not met within \(timeout)", sourceLocation: sourceLocation)
            return
        }
        try await Task.sleep(for: .milliseconds(10))
    }
}
