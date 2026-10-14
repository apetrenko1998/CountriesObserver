//
//  CountryDetailsEntity.swift
//  CountriesDomain
//
//  Created by Anton Petrenko on 11/10/2026.
//

public struct CountryDetailsEntity: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let flag: String
    public let continent: String
    public let capital: String?
    public let currency: String?
    public let languages: [String]

    public init(
        id: String,
        name: String,
        flag: String,
        continent: String,
        capital: String?,
        currency: String?,
        languages: [String]
    ) {
        self.id = id
        self.name = name
        self.flag = flag
        self.continent = continent
        self.capital = capital
        self.currency = currency
        self.languages = languages
    }
}
