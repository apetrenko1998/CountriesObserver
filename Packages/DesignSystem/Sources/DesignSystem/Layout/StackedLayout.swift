//
//  StackedLayout.swift
//  DesignSystem
//
//  Created by Anton Petrenko on 14/10/2026.
//

import SwiftUI

public extension EnvironmentValues {
    @Entry var prefersStackedLayout = false
}

struct StackedLayoutPolicy: ViewModifier {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func body(content: Content) -> some View {
        content.environment(\.prefersStackedLayout, dynamicTypeSize.isAccessibilitySize)
    }
}

public extension View {
    func stackedLayoutPolicy() -> some View {
        modifier(StackedLayoutPolicy())
    }
}
