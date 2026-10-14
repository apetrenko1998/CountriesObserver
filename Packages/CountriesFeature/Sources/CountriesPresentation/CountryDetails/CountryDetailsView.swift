//
//  CountryDetailsView.swift
//  CountriesPresentation
//
//  Created by Anton Petrenko on 11/10/2026.
//

import CountriesDomain
import DesignSystem
import SwiftUI

struct CountryDetailsView: View {
    @State private var viewModel: CountryDetailsViewModel
    @ScaledMetric(relativeTo: .largeTitle) private var flagSize = 96

    init(viewModel: CountryDetailsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .errorState(viewModel.state.failure) { await viewModel.load() }
            .navigationTitle(viewModel.country.name)
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load() }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView()
        case .loaded(let details):
            List {
                Section {
                    header(for: details)
                }
                Section {
                    DetailRow("Capital", value: details.capital ?? notAvailable)
                    DetailRow("Currency", value: details.currency ?? notAvailable)
                    DetailRow("Languages", value: languages(details.languages))
                    DetailRow("Continent", value: details.continent)
                }
            }
        case .failed:
            EmptyView() // Rendered by `errorState`.
        }
    }

    private func header(for details: CountryDetailsEntity) -> some View {
        VStack(spacing: 8) {
            Text(details.flag)
                .font(.system(size: flagSize))
                .accessibilityHidden(true)
            Text(details.name)
                .font(.title.bold())
                .foregroundStyle(.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)
    }

    private var notAvailable: String { "—" }

    private func languages(_ languages: [String]) -> String {
        languages.isEmpty ? notAvailable : languages.formatted(.list(type: .and))
    }
}

/// A labelled value that moves the value under its label at accessibility text sizes,
/// where a side-by-side layout would squeeze long values such as a list of languages.
private struct DetailRow: View {
    let title: LocalizedStringKey
    let value: String

    @Environment(\.prefersStackedLayout) private var prefersStackedLayout

    init(_ title: LocalizedStringKey, value: String) {
        self.title = title
        self.value = value
    }

    var body: some View {
        if prefersStackedLayout {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.textSecondary)
                Text(value)
                    .foregroundStyle(.textPrimary)
            }
            .accessibilityElement(children: .combine)
        } else {
            LabeledContent(title, value: value)
        }
    }
}

#Preview("Loaded") {
    NavigationStack {
        CountryDetailsView(viewModel: CountryDetailsViewModel(
            country: CountryEntity(id: "DE", name: "Germany", flag: "🇩🇪", continent: "Europe"),
            fetchDetails: PreviewFetchCountryDetails(result: .success(CountryDetailsEntity(
                id: "DE",
                name: "Germany",
                flag: "🇩🇪",
                continent: "Europe",
                capital: "Berlin",
                currency: "EUR",
                languages: ["German"]
            )))
        ))
    }
}

#Preview("Error") {
    NavigationStack {
        CountryDetailsView(viewModel: CountryDetailsViewModel(
            country: CountryEntity(id: "DE", name: "Germany", flag: "🇩🇪", continent: "Europe"),
            fetchDetails: PreviewFetchCountryDetails(result: .failure(.offline))
        ))
    }
}

private struct PreviewFetchCountryDetails: FetchCountryDetailsUseCaseInterface {
    let result: Result<CountryDetailsEntity, CountriesError>

    func execute(code: String) async throws -> CountryDetailsEntity {
        try result.get()
    }
}
