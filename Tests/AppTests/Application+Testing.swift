@testable import App
import Foundation
import Vapor

class CreateApp {
    static func makeApp() -> Application {
        let privateKey = ***REMOVED***
        let email = ***REMOVED***
        let projectId = ***REMOVED***

        let config = Config.default()
        let env = try! Environment.detect()
        var services = Services.default()
        let firestoreConfig = FirestoreConfig(projectId: projectId, email: email, privateKey: privateKey)
        services.register(firestoreConfig)

        try! services.register(FirestoreProvider())

        return try! Application(config: config, environment: env, services: services)
    }
}
