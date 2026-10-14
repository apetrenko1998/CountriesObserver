//
//  CountryRow.swift
//  CountriesPresentation
//
//  Created by Anton Petrenko on 14/10/2026.
//

import CountriesDomain
import DesignSystem
import SwiftUI

struct CountryRow: View {
    let country: CountryEntity

    @Environment(\.prefersStackedLayout) private var prefersStackedLayout

    var body: some View {
        HStack {
            layout {
                Text(country.flag)
                    .font(.largeTitle)
                    .accessibilityHidden(true)
                VStack(alignment: .leading) {
                    Text(country.name)
                        .font(.headline)
                        .foregroundStyle(.textPrimary)
                    Text(country.continent)
                        .font(.subheadline)
                        .foregroundStyle(.textSecondary)
                }
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.textTertiary)
                .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
    }

    /// At accessibility text sizes the flag goes above the name, leaving the full row width for the text.
    private var layout: AnyLayout {
        prefersStackedLayout
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 4))
            : AnyLayout(HStackLayout(spacing: 12))
    }
}

#Preview("Stacked") {
    List {
        CountryRow(country: CountryEntity(id: "GS", name: "South Georgia", flag: "🇬🇸", continent: "Antarctica"))
    }
    .environment(\.prefersStackedLayout, true)
    .dynamicTypeSize(.accessibility3)
}
