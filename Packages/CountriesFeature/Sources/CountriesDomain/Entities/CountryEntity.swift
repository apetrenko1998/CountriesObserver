//
//  CountryEntity.swift
//  CountriesDomain
//
//  Created by Anton Petrenko on 11/10/2026.
//

public struct CountryEntity: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let flag: String
    public let continent: String

    public init(id: String, name: String, flag: String, continent: String) {
        self.id = id
        self.name = name
        self.flag = flag
        self.continent = continent
    }
}
