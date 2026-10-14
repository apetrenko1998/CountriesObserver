//
//  Lifetime.swift
//  DependencyInjection
//
//  Created by Anton Petrenko on 11/10/2026.
//

public enum Lifetime: Sendable {
    /// Created on first resolve, then the same instance is returned.
    case singleton
    /// A new instance on every resolve.
    case transient
}
