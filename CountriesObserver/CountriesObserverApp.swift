//
//  CountriesObserverApp.swift
//  CountriesObserver
//
//  Created by Anton Petrenko on 09/10/2026.
//

import CountriesPresentation
import DependencyInjection
import DesignSystem
import SwiftUI

@main
struct CountriesObserverApp: App {
    private let container = DIContainer()
    @State private var countriesCoordinator: CountriesCoordinator

    init() {
        AppAssembly.register(in: container)
        _countriesCoordinator = State(initialValue: container.resolve())
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $countriesCoordinator.path) {
                countriesCoordinator.makeRootView()
                    .navigationDestination(for: CountriesRoute.self) { route in
                        countriesCoordinator.makeView(for: route)
                    }
            }
            .tint(DSColor.accent)
            .stackedLayoutPolicy()
        }
    }
}
