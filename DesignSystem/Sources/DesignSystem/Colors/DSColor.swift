//
//  DSColor.swift
//  DesignSystem
//
//  Created by Anton Petrenko on 11/10/2026.
//

import SwiftUI

public enum DSColor {
    public enum Text {
        public static let primary = Color(uiColor: .label)
        public static let secondary = Color(uiColor: .secondaryLabel)
    }

    public enum Background {
        public static let primary = Color(uiColor: .systemGroupedBackground)
        public static let surface = Color(uiColor: .secondarySystemGroupedBackground)
    }

    public enum Status {
        public static let error = Color(uiColor: .systemRed)
    }

    public static let accent = Color("Accent", bundle: .module)
}
