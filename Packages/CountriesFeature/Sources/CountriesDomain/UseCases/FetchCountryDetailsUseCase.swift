//
//  FetchCountryDetailsUseCase.swift
//  CountriesDomain
//
//  Created by Anton Petrenko on 11/10/2026.
//

public protocol FetchCountryDetailsUseCaseInterface: Sendable {
    func execute(code: String) async throws -> CountryDetailsEntity
}

public struct FetchCountryDetailsUseCase: FetchCountryDetailsUseCaseInterface {
    private let repository: any CountriesRepositoryInterface

    public init(repository: any CountriesRepositoryInterface) {
        self.repository = repository
    }

    public func execute(code: String) async throws -> CountryDetailsEntity {
        try await repository.countryDetails(code: code)
    }
}
