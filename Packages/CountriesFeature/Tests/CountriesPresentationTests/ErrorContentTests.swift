//
//  ErrorContentTests.swift
//  CountriesPresentationTests
//
//  Created by Anton Petrenko on 14/10/2026.
//

import CountriesDomain
@testable import CountriesPresentation
import Testing

struct ErrorContentTests {
    @Test(arguments: [
        (CountriesError.offline, "wifi.exclamationmark"),
        (.notFound, "questionmark.circle"),
        (.server, "exclamationmark.triangle"),
        (.unknown, "exclamationmark.triangle")
    ])
    func iconMatchesCause(error: CountriesError, expectedImage: String) {
        #expect(ErrorContent(error).systemImage == expectedImage)
    }

    @Test func nonDomainErrorFallsBackToGenericContent() {
        struct SomeError: Error {}

        #expect(ErrorContent(SomeError()) == ErrorContent(CountriesError.unknown))
    }
}
