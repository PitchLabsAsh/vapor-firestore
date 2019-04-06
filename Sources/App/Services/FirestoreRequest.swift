//
//  FirestoreRequest.swift
//  App
//
//  Created by Ash Thwaites on 02/04/2019.
//

import Vapor
import JWT


public protocol FirestoreRequest {
//    func send<F: Decodable, T: Content>(req: Request, method: HTTPMethod, path: [String], body: T, headers: HTTPHeaders) throws -> Future<F>
    func getToken() throws -> Future<String>
    func send<F: Decodable, T: Content>(req: Request, method: HTTPMethod, path: String, body: T, headers: HTTPHeaders) throws -> Future<F>
}

public class FirestoreAPIRequest: FirestoreRequest {
    private let decoder = JSONDecoder.firestore
    private let httpClient: Client
    private let basePath: String
    private let baseUrl: URL
    private let email: String
    private let privateKey: String
    private var authTokenExpireAt: Date
    private var authToken: String
    private var signer: JWTSigner?

    public init(httpClient: Client, projectId: String, email: String, privateKey: String) {
        self.basePath = "projects/\(projectId)/databases/(default)/documents/"
        self.baseUrl = URL(string: "https://firestore.googleapis.com/v1/")!
        self.httpClient = httpClient
        self.email = email
        self.privateKey = privateKey
        self.authTokenExpireAt = Date.distantPast
        self.authToken = ""

        do {
            signer = try JWTSigner.rs256(key: .private(pem: self.privateKey))
        } catch {
            print("JWT error: \(error)")
        }
    }

    public func  getToken() throws -> Future<String> {
        guard let signer = signer else {
            throw FirestoreError.signing
        }

        if (authTokenExpireAt > Date() ) {
            return Future.map(on: self.httpClient.container) { self.authToken }
        }

        let jwt = JWT(header: JWTHeader(alg: "RS256"), payload: Firestore.Auth.Payload(iss: IssuerClaim(value: self.email)))
        let data = try signer.sign(jwt)
        let jwtString = String(data: data, encoding: .utf8)!

        var headers = HTTPHeaders([])
        headers.add(name: HTTPHeaderName.contentType, value: "application/x-www-form-urlencoded")

        let body = Firestore.Auth.Request(grantType: "urn:ietf:params:oauth:grant-type:jwt-bearer", assertion: jwtString)
        let req = Request(using: httpClient.container)
        try req.content.encode(body, as: .urlEncodedForm)
        req.http.url = URL(string: "https://www.googleapis.com/oauth2/v4/token")!
        req.http.method = .POST

        return httpClient.send(req).flatMap(to: Firestore.Auth.Response.self) { response in
            return try response.content.decode(Firestore.Auth.Response.self)
        }.map(to: String.self) { authResponse in
            self.authToken = authResponse.accessToken
            self.authTokenExpireAt = Date().addingTimeInterval(TimeInterval(authResponse.expiresIn - 10))
            return authResponse.accessToken
        }
    }

    private func createRequest<T: Content>(method: HTTPMethod, path: String, body: T, headers: HTTPHeaders)throws -> Future<Request> {
        return try getToken().map({ (accessToken) in
            let url = (path.hasPrefix(self.basePath)) ? self.baseUrl : self.baseUrl.appendingPathComponent(self.basePath)
            let uri = url.appendingPathComponent(path).absoluteString
            let request = Request(using: self.httpClient.container)
            try request.content.encode(body)

            var hdrs = HTTPHeaders()
            hdrs.bearerAuthorization = BearerAuthorization(token: self.authToken)

            request.http.method = method
            request.http.headers = hdrs
            request.http.url = URL(string: uri)!
            return request
        })
    }

    public func send<F: Decodable, T: Content>(req: Request, method: HTTPMethod, path: String, body: T, headers: HTTPHeaders) throws -> Future<F> {
        return try self.createRequest(method: method, path: path, body: body, headers: headers).flatMap({ (request) in
            return self.httpClient.send(request).flatMap(to: F.self) { response in
                guard response.http.status == .ok else { throw FirestoreError.requestFailed }
                return try self.decoder.decode(F.self, from: response.http, maxSize: 65_536, on: req)
            }
        })
    }
}

