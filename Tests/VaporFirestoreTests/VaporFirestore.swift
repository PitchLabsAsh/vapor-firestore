import Vapor
import VaporFirestore
import XCTest
import Nimble

struct TestFields: Codable {
    var title: Firestore.StringValue
    var subTitle: Firestore.StringValue
}

struct TestUpdateFields: Codable {
    var title: Firestore.StringValue
}


final class VaporFirestoreTests: XCTestCase {

    var app: Application!

    static let allTests = [
        ("testAuthToken", testAuthToken,
         "testCreatDoc", testCreateDoc,
         "testUpdateDoc", testUpdateDoc,
         "testListDocs", testListDocs,
         "testGetDoc", testGetDoc)
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
        do {
            let client = try self.app.make(FirestoreClient.self)
            let request = Request(using: self.app)
            let testObject = TestFields(title: Firestore.StringValue("A title"), subTitle: Firestore.StringValue("A subtitle"))

            let result = try client.firestore.createDocument(path: "test", fields: testObject, on: request).wait()
            expect(result).toNot(beNil())

            print("Test object-id: \( (result.name as NSString).lastPathComponent)")
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testUpdateDoc() throws {
        do {
            let client = try self.app.make(FirestoreClient.self)
            let request = Request(using: self.app)
            let testObject = TestUpdateFields(title: Firestore.StringValue("An updated title again"))
            let result = try client.firestore.updateDocument(path: "test/<object-id>", fields: testObject, updateMask: ["title"], on: request).wait()

            expect(result).toNot(beNil())
        } catch {
            XCTFail(error.localizedDescription)
        }
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

    func testGetDoc() throws {
        do {
            let client = try self.app.make(FirestoreClient.self)
            let request = Request(using: self.app)

            let result: Firestore.Document<TestFields> = try client.firestore.getDocument(path: "test/<object-id>", on: request).wait()

            expect(result).toNot(beNil())
            expect(result.fields?.title).toNot(beNil())
            expect(result.fields?.subTitle).toNot(beNil())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
