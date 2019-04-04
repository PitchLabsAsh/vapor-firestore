@testable import App
import Vapor
import XCTest
import Nimble

final class AppTests: XCTestCase {

    var app: Application!

    static let allTests = [
        ("testAuthToken", testAuthToken)
    ]

    override func setUp() {
        super.setUp()
        self.app = CreateApp.makeApp()
    }

    func testAuthToken() throws {
        do {
            let client = try self.app.make(FirestoreClient.self)
            let request = Request(using: self.app)

            let result = try client.firestore.test(req: request).wait()

            expect(result).toNot(beEmpty())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
