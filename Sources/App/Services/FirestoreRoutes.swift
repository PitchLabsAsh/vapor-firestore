//
//  FirestoreRoutes.swift
//  App
//
//  Created by Ash Thwaites on 02/04/2019.
//

import Vapor

public struct FirestoreRoutes {
    private let request: FirestoreRequest

    init(request: FirestoreRequest) {
        self.request = request
    }

    public func test(req: Request) throws -> Future<String> {
        let sendReq: Future<String> = try self.request.getToken()
        return sendReq
    }

    public func getDocument<T: Decodable>(path: String, on req: Request) throws -> Future<Firestore.Document<T>> {
        let sendReq: Future<Firestore.Document<T>> = try self.request.send(
            method: .GET,
            path: path,
            body: .empty,
            headers: [:])
        return sendReq
    }

    public func listDocuments<T: Decodable>(path: String, on req: Request) throws -> Future<[Firestore.Document<T>]> {
        let sendReq: Future<Firestore.List.Response<T>> = try self.request.send(
            method: .GET,
            path: path,
            body: .empty,
            headers: [:])
        return sendReq.map(to: [Firestore.Document<T>].self) { response in
            return response.documents
        }
    }

    func createDocument<T: Codable>(path: String, body: T, on req: Request) throws -> Future<Firestore.Document<T>> {
        let requestBody = try JSONEncoder().encode(["fields": body]).convertToHTTPBody()
        let sendReq: Future<Firestore.Document<T>> = try self.request.send(
            method: .POST,
            path: path,
            body: requestBody,
            headers: [:])
        return sendReq
    }

}
