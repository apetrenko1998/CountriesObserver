//
//  CountriesCoordinator.swift
//  CountriesPresentation
//
//  Created by Anton Petrenko on 11/10/2026.
//

import CountriesDomain
import DependencyInjection
import Observation
import SwiftUI

@MainActor
@Observable
public final class CountriesCoordinator: CountriesCoordinating {
    public var path: [CountriesRoute] = []

    @ObservationIgnored private weak var resolver: (any DependencyResolver)?

    public init(resolver: any DependencyResolver) {
        self.resolver = resolver
    }

    private var dependencies: any DependencyResolver {
        guard let resolver else {
            preconditionFailure("CountriesCoordinator: the dependency container was deallocated")
        }
        return resolver
    }

    public func makeRootView() -> some View {
        CountriesView(viewModel: makeCountriesViewModel())
    }

    private func makeCountriesViewModel() -> CountriesViewModel {
        CountriesViewModel(
            fetchCountries: dependencies.resolve(),
            coordinator: self
        )
    }

    @ViewBuilder
    public func makeView(for route: CountriesRoute) -> some View {
        switch route {
        case .details(let country):
            CountryDetailsView(
                viewModel: CountryDetailsViewModel(
                    country: country,
                    fetchDetails: dependencies.resolve()
                )
            )
        }
    }

    func showCountryDetails(_ country: CountryEntity) {
        path.append(.details(country))
    }

    func pop() {
        _ = path.popLast()
    }

    func popToRoot() {
        path.removeAll()
    }
}
