//
//  CountriesError+NetworkError.swift
//  CountriesData
//
//  Created by Anton Petrenko on 11/10/2026.
//

import CountriesDomain
import Networking

extension CountriesError {
    init(_ error: NetworkError) {
        switch error {
        case .offline, .timeout:
            self = .offline
        case .server, .graphQL, .noData, .decoding:
            self = .server
        case .unknown:
            self = .unknown
        }
    }
}
