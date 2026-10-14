//
//  DependencyResolver.swift
//  DependencyInjection
//
//  Created by Anton Petrenko on 11/10/2026.
//

@MainActor
public protocol DependencyResolver: AnyObject {
    func resolve<Service>(_ type: Service.Type) -> Service
}

public extension DependencyResolver {
    func resolve<Service>() -> Service {
        resolve(Service.self)
    }
}
