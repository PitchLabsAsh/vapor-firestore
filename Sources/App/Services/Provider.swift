//
//  Provider.swift
//  App
//
//  Created by Ash Thwaites on 02/04/2019.
//

import Vapor


public struct FirestoreConfig: Service {
    public let privateKey: String
    public let email: String
    public let projectId: String

    public init(projectId: String, email: String, privateKey: String) {
        self.projectId = projectId
        self.email = email
        self.privateKey = privateKey
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
            return FirestoreClient(client: httpClient, projectId: config.projectId, email: config.email, privateKey: config.privateKey)
        }
    }
}



public struct FirestoreClient: Service {
    public var firestore: FirestoreRoutes

    internal init(client: Client, projectId: String, email: String, privateKey: String) {
        let apiRequest = FirestoreAPIRequest(httpClient: client, projectId: projectId, email: email, privateKey: privateKey)
        firestore = FirestoreRoutes(request: apiRequest)
    }
}
