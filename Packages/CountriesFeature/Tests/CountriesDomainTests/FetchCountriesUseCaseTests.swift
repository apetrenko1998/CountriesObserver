//
//  FetchCountriesUseCaseTests.swift
//  CountriesDomainTests
//
//  Created by Anton Petrenko on 11/10/2026.
//

import CountriesDomain
import Foundation
import Testing

struct FetchCountriesUseCaseTests {
    @Test(arguments: [("", nil), ("   ", nil), ("  ger ", "ger")] as [(String, String?)])
    func queryIsTrimmedAndBlankMeansAll(query: String, expected: String?) async throws {
        let repository = RecordingRepository()

        _ = try await FetchCountriesUseCase(repository: repository).execute(query: query, forceRefresh: false)

        #expect(repository.receivedNames == [expected])
    }
}

private final class RecordingRepository: CountriesRepositoryInterface, @unchecked Sendable {
    private let lock = NSLock()
    private var names: [String?] = []

    var receivedNames: [String?] { lock.withLock { names } }

    func countries(nameContaining: String?, forceRefresh: Bool) async throws -> [CountryEntity] {
        lock.withLock { names.append(nameContaining) }
        return []
    }

    func countryDetails(code: String) async throws -> CountryDetailsEntity {
        throw CountriesError.notFound
    }
}
