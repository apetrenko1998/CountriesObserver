//
//  NameFilter.swift
//  CountriesData
//
//  Created by Anton Petrenko on 11/10/2026.
//

/// Builds the regex for the API's `name` filter.
///
/// The API matches regexes case-sensitively and rejects inline flags such as `(?i)`,
/// so every letter becomes a character class (`ger` → `[gG][eE][rR]`).
enum NameFilter {
    private static let metacharacters = Set(#"\^$.|?*+()[]{}-/"#)

    static func regex(for text: String) -> String {
        text.map { character in
            let lower = character.lowercased()
            let upper = character.uppercased()
            if lower != upper, lower.count == 1, upper.count == 1 {
                return "[\(lower)\(upper)]"
            }
            return metacharacters.contains(character) ? #"\"# + String(character) : String(character)
        }
        .joined()
    }
}
