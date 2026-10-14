//
//  CountryEntity+Mapping.swift
//  CountriesData
//
//  Created by Anton Petrenko on 11/10/2026.
//

import CountriesDomain

extension CountryEntity {
    init(summary: CountrySummary) {
        self.init(
            id: summary.code,
            name: summary.name,
            flag: summary.emoji,
            continent: summary.continent.name
        )
    }
}

extension CountryDetailsEntity {
    init(_ country: CountryDetailsQuery.Data.Country) {
        let summary = country.fragments.countrySummary
        self.init(
            id: summary.code,
            name: summary.name,
            flag: summary.emoji,
            continent: summary.continent.name,
            capital: country.capital,
            currency: country.currency,
            languages: country.languages.map(\.name)
        )
    }
}
