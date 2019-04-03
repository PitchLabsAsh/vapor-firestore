//
//  FirestoreRequest.swift
//  App
//
//  Created by Ash Thwaites on 02/04/2019.
//

import Vapor


public protocol FirestoreRequest {
    func send<F: Decodable, T: Content>(req: Request, method: HTTPMethod, path: [String], body: T, headers: HTTPHeaders) throws -> Future<F>
}

public class FirestoreAPIRequest: FirestoreRequest {
    private let decoder = JSONDecoder()
    private let httpClient: Client
    private let basePath: String
    private let email: String
    private let privateKey: String
    private var expireDate: Date?
    private var accessToken: String?

    public init(httpClient: Client, basePath: String, email: String, privateKey: String) {
        self.httpClient = httpClient
        self.basePath = basePath
        self.email = email
        self.privateKey = privateKey
        self.expireDate = nil
        self.accessToken = nil
    }


    public func send<F: Decodable, T: Content>(req: Request, method: HTTPMethod, path: [String], body: T, headers: HTTPHeaders) throws -> Future<F> {
        return try self.createRequest(method: method, path: path, query: nil, body: body, headers: headers).flatMap({ (request) in
            return self.httpClient.send(request).flatMap(to: F.self) { response in
                guard response.http.status == .ok else { throw FernoError.requestFailed }
                return try self.decoder.decode(F.self, from: response.http, maxSize: 65_536, on: req)
            }
        })
    }

}
