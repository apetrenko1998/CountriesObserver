//
//  DIContainer.swift
//  DependencyInjection
//
//  Created by Anton Petrenko on 11/10/2026.
//

@MainActor
public final class DIContainer: DependencyResolver {
    private struct Registration {
        let lifetime: Lifetime
        let factory: @MainActor (any DependencyResolver) -> Any
    }

    private var registrations: [ObjectIdentifier: Registration] = [:]
    private var singletons: [ObjectIdentifier: Any] = [:]
    private var resolving: [String] = []

    public init() {}

    public func register<Service>(
        _ type: Service.Type = Service.self,
        lifetime: Lifetime = .transient,
        factory: @escaping @MainActor (any DependencyResolver) -> Service
    ) {
        let key = ObjectIdentifier(type)
        registrations[key] = Registration(lifetime: lifetime, factory: factory)
        singletons[key] = nil
    }

    public func resolve<Service>(_ type: Service.Type) -> Service {
        let key = ObjectIdentifier(type)
        let name = String(describing: type)
        guard let registration = registrations[key] else {
            preconditionFailure("DIContainer: no registration for \(name)")
        }
        if registration.lifetime == .singleton, let instance = singletons[key] as? Service {
            return instance
        }
        guard !resolving.contains(name) else {
            preconditionFailure("DIContainer: dependency cycle \((resolving + [name]).joined(separator: " → "))")
        }

        resolving.append(name)
        defer { resolving.removeLast() }
        guard let instance = registration.factory(self) as? Service else {
            preconditionFailure("DIContainer: factory for \(name) returned a different type")
        }
        if registration.lifetime == .singleton {
            singletons[key] = instance
        }
        return instance
    }
}
