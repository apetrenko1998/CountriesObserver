//
//  AppAssembly.swift
//  CountriesObserver
//
//  Created by Anton Petrenko on 11/10/2026.
//

import CountriesData
import CountriesDomain
import CountriesPresentation
import DependencyInjection
import Foundation
import Networking

@MainActor
enum AppAssembly {
    static func register(in container: DIContainer) {
        registerNetworking(in: container)
        registerCountries(in: container)
    }

    private static func registerNetworking(in container: DIContainer) {
        container.register((any GraphQLClient).self, lifetime: .singleton) { _ in
            guard let endpoint = URL(string: "https://countries.trevorblades.com/graphql") else {
                preconditionFailure("Invalid GraphQL endpoint URL")
            }
            return GraphQLNetworkClient(url: endpoint)
        }
    }

    private static func registerCountries(in container: DIContainer) {
        container.register((any CountriesRepositoryInterface).self, lifetime: .singleton) { resolver in
            CountriesRepository(client: resolver.resolve())
        }
        container.register((any FetchCountriesUseCaseInterface).self) { resolver in
            FetchCountriesUseCase(repository: resolver.resolve())
        }
        container.register((any FetchCountryDetailsUseCaseInterface).self) { resolver in
            FetchCountryDetailsUseCase(repository: resolver.resolve())
        }
        container.register(CountriesCoordinator.self, lifetime: .singleton) { resolver in
            CountriesCoordinator(resolver: resolver)
        }
    }
}
