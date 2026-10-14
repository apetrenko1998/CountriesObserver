//
//  CountryDetailsViewModel.swift
//  CountriesPresentation
//
//  Created by Anton Petrenko on 11/10/2026.
//

import CountriesDomain
import Foundation
import Observation

@MainActor
@Observable
final class CountryDetailsViewModel {
    enum State: Equatable {
        case loading
        case loaded(CountryDetailsEntity)
        case failed(ErrorContent)

        var failure: ErrorContent? {
            if case .failed(let error) = self { error } else { nil }
        }
    }

    let country: CountryEntity
    private(set) var state: State = .loading

    private let fetchDetails: any FetchCountryDetailsUseCaseInterface

    /// Must stay free of side effects: `@State(initialValue:)` in the view evaluates it on every view init.
    /// Loading starts from the view's `.task`.
    init(country: CountryEntity, fetchDetails: any FetchCountryDetailsUseCaseInterface) {
        self.country = country
        self.fetchDetails = fetchDetails
    }

    func load() async {
        state = .loading
        do {
            state = .loaded(try await fetchDetails.execute(code: country.id))
        } catch is CancellationError {
            // The screen was dismissed; nothing to show.
        } catch {
            state = .failed(ErrorContent(error))
        }
    }
}
