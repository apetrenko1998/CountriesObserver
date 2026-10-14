//
//  CountriesError.swift
//  CountriesDomain
//
//  Created by Anton Petrenko on 11/10/2026.
//

public enum CountriesError: Error, Equatable, Sendable {
    case offline
    case server
    case notFound
    case unknown
}
