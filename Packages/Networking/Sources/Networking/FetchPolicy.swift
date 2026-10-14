//
//  FetchPolicy.swift
//  Networking
//
//  Created by Anton Petrenko on 11/10/2026.
//

public enum FetchPolicy: Sendable, Equatable {
    case cacheFirst
    case networkOnly
}
