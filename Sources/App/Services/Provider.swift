//
//  Provider.swift
//  App
//
//  Created by Ash Thwaites on 02/04/2019.
//

import Vapor


public struct FirestoreConfig: Service {
    public let apiKey: String
    public let testApiKey: String?

    public init(apiKey: String) {
        self.apiKey = apiKey
        self.testApiKey = nil
    }

    public init(productionKey: String, testKey: String) {
        self.apiKey = productionKey
        self.testApiKey = testKey
    }
}

public final class FirestoreProvider: Provider {

    public init() { }

    public func boot(_ worker: Container) throws { }

    public func didBoot(_ worker: Container) throws -> EventLoopFuture<Void> {
        return .done(on: worker)
    }

    public func register(_ services: inout Services) throws {
        services.register { (container) -> FirestoreClient in
            let httpClient = try container.make(Client.self)
            let config = try container.make(FirestoreConfig.self)
            return FirestoreClient(apiKey: config.apiKey, testKey: config.testApiKey, client: httpClient)
        }
    }
}



public struct FirestoreClient: Service {
    public var routes: FirestoreRoutes

    internal init(client: Client, basePath: String, email: String, privateKey: String) {
        let apiRequest = FirestoreAPIRequest(httpClient: client, basePath: basePath, email: email, privateKey: privateKey)

        routes = FirestoreRoutes(request: apiRequest)

    }
}
