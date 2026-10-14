//
//  DIContainerTests.swift
//  DependencyInjectionTests
//
//  Created by Anton Petrenko on 11/10/2026.
//

@testable import DependencyInjection
import Testing

private protocol Service: AnyObject {}
private final class ServiceImpl: Service {}
private final class OtherServiceImpl: Service {}
private final class Consumer {
    let service: any Service

    init(service: any Service) {
        self.service = service
    }
}

@MainActor
struct DIContainerTests {
    @Test func resolvesRegisteredProtocol() {
        let container = DIContainer()
        container.register((any Service).self) { _ in ServiceImpl() }

        let service: any Service = container.resolve()

        #expect(service is ServiceImpl)
    }

    @Test func transientCreatesNewInstanceEachTime() {
        let container = DIContainer()
        container.register((any Service).self, lifetime: .transient) { _ in ServiceImpl() }

        let first: any Service = container.resolve()
        let second: any Service = container.resolve()

        #expect(first !== second)
    }

    @Test func singletonReturnsSameInstance() {
        let container = DIContainer()
        container.register((any Service).self, lifetime: .singleton) { _ in ServiceImpl() }

        let first: any Service = container.resolve()
        let second: any Service = container.resolve()

        #expect(first === second)
    }

    @Test func singletonIsCreatedLazily() {
        let container = DIContainer()
        var created = 0
        container.register((any Service).self, lifetime: .singleton) { _ in
            created += 1
            return ServiceImpl()
        }

        #expect(created == 0)
        let _: any Service = container.resolve()
        let _: any Service = container.resolve()
        #expect(created == 1)
    }

    @Test func factoryResolvesItsDependencies() {
        let container = DIContainer()
        container.register((any Service).self, lifetime: .singleton) { _ in ServiceImpl() }
        container.register(Consumer.self) { container in Consumer(service: container.resolve()) }

        let consumer: Consumer = container.resolve()
        let service: any Service = container.resolve()

        #expect(consumer.service === service)
    }

    @Test func laterRegistrationReplacesEarlierOne() {
        let container = DIContainer()
        container.register((any Service).self, lifetime: .singleton) { _ in ServiceImpl() }
        let _: any Service = container.resolve()

        container.register((any Service).self, lifetime: .singleton) { _ in OtherServiceImpl() }
        let service: any Service = container.resolve()

        #expect(service is OtherServiceImpl)
    }
}
