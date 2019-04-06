@testable import App
import Vapor
import XCTest
import Nimble

struct TestFields: Codable {
    var title: Firestore.StringValue
    var subTitle: Firestore.StringValue
}


final class AppTests: XCTestCase {

    var app: Application!

    static let allTests = [
        ("testAuthToken", testAuthToken,
         "testCreatDoc", testCreateDoc,
         "testListDocs", testListDocs)
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

    func testCreateDoc() throws {
//        do {
//            let client = try self.app.make(FirestoreClient.self)
//            let request = Request(using: self.app)
//            let testObject = TestFields(title: Firestore.StringValue("A title"), subTitle: Firestore.StringValue("A subtitle"))
//
//            let result = try client.firestore.createDocument(path: "test", body: testObject, on: request).wait()
//
//            expect(result).toNot(beNil())
//        } catch {
//            XCTFail(error.localizedDescription)
//        }
    }

    func testListDocs() throws {
        do {
            let client = try self.app.make(FirestoreClient.self)
            let request = Request(using: self.app)

            let result: [Firestore.Document<TestFields>] = try client.firestore.listDocuments(path: "test", on: request).wait()

            expect(result).toNot(beNil())
            expect(result[0].fields?.title).toNot(beNil())
            expect(result[0].fields?.subTitle).toNot(beNil())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
