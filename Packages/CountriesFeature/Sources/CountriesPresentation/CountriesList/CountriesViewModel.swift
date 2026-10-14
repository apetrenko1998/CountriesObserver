//
//  CountriesViewModel.swift
//  CountriesPresentation
//
//  Created by Anton Petrenko on 09/10/2026.
//

import Combine
import CountriesDomain
import Foundation
import Observation

@MainActor
@Observable
final class CountriesViewModel {
    enum State: Equatable {
        case loading
        case loaded([CountryEntity])
        case empty(query: String)
        case failed(ErrorContent)

        var failure: ErrorContent? {
            if case .failed(let error) = self { error } else { nil }
        }
    }

    private(set) var state: State = .loading
    /// A search is in flight while the previous results stay on screen.
    private(set) var isSearching = false

    var searchText = "" {
        didSet {
            guard searchText != oldValue else { return }
            searchTextSubject.send(searchText)
        }
    }

    private let fetchCountries: any FetchCountriesUseCaseInterface

    @ObservationIgnored private weak var coordinator: (any CountriesCoordinating)?

    @ObservationIgnored private let debounceInterval: DispatchQueue.SchedulerTimeType.Stride
    @ObservationIgnored private lazy var searchTextSubject = makeSearchPipeline()
    @ObservationIgnored private var searchCancellable: AnyCancellable?
    @ObservationIgnored private var searchTask: Task<Void, Never>?
    @ObservationIgnored private var hasCompletedLoad = false
    /// Incremented by every `load()`; only the latest one may change `state`.
    @ObservationIgnored private var generation = 0

    init(
        fetchCountries: any FetchCountriesUseCaseInterface,
        coordinator: any CountriesCoordinating,
        debounceInterval: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(300)
    ) {
        self.fetchCountries = fetchCountries
        self.coordinator = coordinator
        self.debounceInterval = debounceInterval
    }

    func select(_ country: CountryEntity) {
        coordinator?.showCountryDetails(country)
    }

    func loadIfNeeded() async {
        guard !hasCompletedLoad else { return }
        await load()
    }

    func load(forceRefresh: Bool = false) async {
        generation += 1
        let requestGeneration = generation
        let previousState = state
        if case .loaded = state {
            // Keep the current results instead of flashing a spinner. Pull to refresh has its own indicator.
            isSearching = !forceRefresh
        } else {
            isSearching = false
            state = .loading
        }
        defer {
            if requestGeneration == generation {
                isSearching = false
            }
        }
        let query = searchText
        do {
            let countries = try await fetchCountries.execute(query: query, forceRefresh: forceRefresh)
            guard requestGeneration == generation else { return }
            hasCompletedLoad = true
            state = countries.isEmpty ? .empty(query: query) : .loaded(countries)
        } catch is CancellationError {
            // A newer request owns `state` now; otherwise nothing replaces this one, so undo `.loading`.
            guard requestGeneration == generation else { return }
            state = previousState
        } catch {
            guard requestGeneration == generation else { return }
            hasCompletedLoad = true
            state = .failed(ErrorContent(error))
        }
    }

    private func makeSearchPipeline() -> PassthroughSubject<String, Never> {
        let subject = PassthroughSubject<String, Never>()
        searchCancellable = subject
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .debounce(for: debounceInterval, scheduler: DispatchQueue.main)
            .prepend("")
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in
                MainActor.assumeIsolated {
                    self?.search()
                }
            }
        return subject
    }

    private func search() {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            await self?.load()
        }
    }
}
