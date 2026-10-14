//
//  StubFetchDetails.swift
//  CountriesPresentationTests
//
//  Created by Anton Petrenko on 11/10/2026.
//

import CountriesDomain
import Foundation

final class StubFetchDetails: FetchCountryDetailsUseCaseInterface, @unchecked Sendable {
    private let lock = NSLock()
    private var _result: Result<CountryDetailsEntity, CountriesError>
    private var _requestedCodes: [String] = []

    init(result: Result<CountryDetailsEntity, CountriesError>) {
        _result = result
    }

    var result: Result<CountryDetailsEntity, CountriesError> {
        get { lock.withLock { _result } }
        set { lock.withLock { _result = newValue } }
    }

    var requestedCodes: [String] { lock.withLock { _requestedCodes } }

    func execute(code: String) async throws -> CountryDetailsEntity {
        try lock.withLock {
            _requestedCodes.append(code)
            return try _result.get()
        }
    }
}
