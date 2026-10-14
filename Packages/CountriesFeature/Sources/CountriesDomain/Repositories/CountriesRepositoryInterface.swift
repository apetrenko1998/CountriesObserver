//
//  CountriesRepositoryInterface.swift
//  CountriesDomain
//
//  Created by Anton Petrenko on 11/10/2026.
//

public protocol CountriesRepositoryInterface: Sendable {
    func countries(nameContaining: String?, forceRefresh: Bool) async throws -> [CountryEntity]
    func countryDetails(code: String) async throws -> CountryDetailsEntity
}
