//
//  StubFetchCountries.swift
//  CountriesPresentationTests
//
//  Created by Anton Petrenko on 11/10/2026.
//

import CountriesDomain
import Foundation

final class StubFetchCountries: FetchCountriesUseCaseInterface, @unchecked Sendable {
    struct Call: Equatable {
        let query: String
        let forceRefresh: Bool
    }

    private let lock = NSLock()
    private var _result: Result<[CountryEntity], CountriesError>
    private var _calls: [Call] = []
    private var _thrownError: (any Error)?

    init(result: Result<[CountryEntity], CountriesError>) {
        _result = result
    }

    var result: Result<[CountryEntity], CountriesError> {
        get { lock.withLock { _result } }
        set { lock.withLock { _result = newValue } }
    }

    var calls: [Call] { lock.withLock { _calls } }

    var thrownError: (any Error)? {
        get { lock.withLock { _thrownError } }
        set { lock.withLock { _thrownError = newValue } }
    }

    func execute(query: String, forceRefresh: Bool) async throws -> [CountryEntity] {
        try lock.withLock {
            _calls.append(Call(query: query, forceRefresh: forceRefresh))
            if let thrownError = _thrownError {
                throw thrownError
            }
            return try _result.get()
        }
    }
}
