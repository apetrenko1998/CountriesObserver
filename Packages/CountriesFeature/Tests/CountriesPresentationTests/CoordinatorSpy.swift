//
//  CoordinatorSpy.swift
//  CountriesPresentationTests
//
//  Created by Anton Petrenko on 11/10/2026.
//

import CountriesDomain
@testable import CountriesPresentation

@MainActor
final class CoordinatorSpy: CountriesCoordinating {
    private(set) var shownDetails: [CountryEntity] = []

    func showCountryDetails(_ country: CountryEntity) {
        shownDetails.append(country)
    }
}
