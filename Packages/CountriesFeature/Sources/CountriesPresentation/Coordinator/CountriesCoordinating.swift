//
//  CountriesCoordinating.swift
//  CountriesPresentation
//
//  Created by Anton Petrenko on 11/10/2026.
//

import CountriesDomain

@MainActor
protocol CountriesCoordinating: AnyObject {
    func showCountryDetails(_ country: CountryEntity)
}
