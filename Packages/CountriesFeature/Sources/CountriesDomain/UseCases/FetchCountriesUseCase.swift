//
//  FetchCountriesUseCase.swift
//  CountriesDomain
//
//  Created by Anton Petrenko on 11/10/2026.
//

import Foundation

public protocol FetchCountriesUseCaseInterface: Sendable {
    func execute(query: String, forceRefresh: Bool) async throws -> [CountryEntity]
}

public struct FetchCountriesUseCase: FetchCountriesUseCaseInterface {
    private let repository: any CountriesRepositoryInterface

    public init(repository: any CountriesRepositoryInterface) {
        self.repository = repository
    }

    public func execute(query: String, forceRefresh: Bool) async throws -> [CountryEntity] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return try await repository.countries(
            nameContaining: trimmed.isEmpty ? nil : trimmed,
            forceRefresh: forceRefresh
        )
    }
}
