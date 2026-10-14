//
//  ScriptedFetchCountries.swift
//  CountriesPresentationTests
//
//  Created by Anton Petrenko on 11/10/2026.
//

import CountriesDomain

final class ScriptedFetchCountries: FetchCountriesUseCaseInterface, Sendable {
    private let script: @Sendable (String) -> (delay: Duration, countries: [CountryEntity])

    init(script: @escaping @Sendable (String) -> (delay: Duration, countries: [CountryEntity])) {
        self.script = script
    }

    func execute(query: String, forceRefresh: Bool) async throws -> [CountryEntity] {
        let answer = script(query)
        try await Task.sleep(for: answer.delay)
        return answer.countries
    }
}
