//
//  CountriesView.swift
//  CountriesPresentation
//
//  Created by Anton Petrenko on 09/10/2026.
//

import CountriesDomain
import DependencyInjection
import SwiftUI

struct CountriesView: View {
    @State private var viewModel: CountriesViewModel

    init(viewModel: CountriesViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .errorState(viewModel.state.failure) { await viewModel.load() }
            .navigationTitle("Countries")
            .searchable(text: $viewModel.searchText, prompt: "Search by name")
            .task { await viewModel.loadIfNeeded() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .loaded(let countries):
            List(countries) { country in
                Button {
                    viewModel.select(country)
                } label: {
                    CountryRow(country: country)
                }
            }
            .refreshable { await viewModel.load(forceRefresh: true) }
            .overlay {
                if viewModel.isSearching {
                    ProgressView()
                        .accessibilityLabel("Searching")
                }
            }
        case .empty(let query):
            if query.isEmpty {
                ContentUnavailableView("No Countries", systemImage: "globe")
            } else {
                ContentUnavailableView.search(text: query)
            }
        case .failed:
            EmptyView() // Rendered by `errorState`.
        }
    }
}

#Preview {
    @Previewable @State var coordinator = CountriesCoordinator(resolver: PreviewDependencies.container)
    NavigationStack(path: $coordinator.path) {
        coordinator.makeRootView()
            .navigationDestination(for: CountriesRoute.self) { coordinator.makeView(for: $0) }
    }
}

@MainActor
private enum PreviewDependencies {
    static let container: DIContainer = {
        let container = DIContainer()
        container.register((any FetchCountriesUseCaseInterface).self) { _ in PreviewFetchCountries() }
        container.register((any FetchCountryDetailsUseCaseInterface).self) { _ in PreviewFetchCountryDetails() }
        return container
    }()
}

private struct PreviewFetchCountryDetails: FetchCountryDetailsUseCaseInterface {
    func execute(code: String) async throws -> CountryDetailsEntity {
        CountryDetailsEntity(
            id: code,
            name: "Germany",
            flag: "🇩🇪",
            continent: "Europe",
            capital: "Berlin",
            currency: "EUR",
            languages: ["German"]
        )
    }
}

private struct PreviewFetchCountries: FetchCountriesUseCaseInterface {
    func execute(query: String, forceRefresh: Bool) async throws -> [CountryEntity] {
        [
            CountryEntity(id: "DE", name: "Germany", flag: "🇩🇪", continent: "Europe"),
            CountryEntity(id: "JP", name: "Japan", flag: "🇯🇵", continent: "Asia")
        ]
    }
}
