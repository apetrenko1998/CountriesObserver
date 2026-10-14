//
//  NameFilterTests.swift
//  CountriesDataTests
//
//  Created by Anton Petrenko on 11/10/2026.
//

@testable import CountriesData
import Testing

struct NameFilterTests {
    @Test func lettersBecomeCaseInsensitiveClasses() {
        #expect(NameFilter.regex(for: "Ger") == "[gG][eE][rR]")
    }

    @Test func metacharactersAreEscaped() {
        #expect(NameFilter.regex(for: "St. (x)") == #"[sS][tT]\. \([xX]\)"#)
    }

    @Test func nonLetterCharactersAreKeptAsIs() {
        #expect(NameFilter.regex(for: "1 '") == "1 '")
    }
}
