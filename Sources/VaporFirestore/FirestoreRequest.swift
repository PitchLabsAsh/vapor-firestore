//
//  FirestoreRequest.swift
//  App
//
//  Created by Ash Thwaites on 02/04/2019.
//

import Vapor
import JWT


public protocol FirestoreRequest {
    func getToken() throws -> Future<String>
    func send<F: Decodable>(method: HTTPMethod, path: String, query:String, body: HTTPBody, headers: HTTPHeaders) throws -> Future<F>
}

public class FirestoreAPIRequest: FirestoreRequest {
    private let decoder = JSONDecoder.firestore
    private let encoder = JSONEncoder.firestore
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

    public func send<F: Decodable>(method: HTTPMethod, path: String, query:String, body: HTTPBody, headers: HTTPHeaders) throws -> Future<F> {
        return try getToken().flatMap({ (accessToken) in
            return try self._send(method: method, path: path, query: query, body: body, headers: headers, accessToken: accessToken).flatMap(to: F.self) { response in
                return try self.decoder.decode(F.self, from: response.http, maxSize: 65_536, on: self.httpClient.container)
            }
        })
    }


    public func _send(method: HTTPMethod, path: String, query:String, body: HTTPBody, headers: HTTPHeaders, accessToken: String) throws -> Future<Response> {
        let url = (path.hasPrefix(self.basePath)) ? self.baseUrl : self.baseUrl.appendingPathComponent(self.basePath)
        let uri = url.appendingPathComponent(path).absoluteString

        var finalHeaders: HTTPHeaders = [:]
        finalHeaders.add(name: .contentType, value: MediaType.json.description)
        finalHeaders.add(name: .authorization, value: "Bearer \(accessToken)")
        headers.forEach { finalHeaders.replaceOrAdd(name: $0.name, value: $0.value) }

        return httpClient.send(method, headers: finalHeaders, to: "\(uri)?\(query)", beforeSend: { $0.http.body = body }).flatMap({ response in
            guard (200...299).contains(response.http.status.code) else {
                return try self.decoder.decode(FirestoreErrorResponse.self, from: response.http, maxSize: 65_536, on: self.httpClient.container).map { error in
                    throw FirestoreError.response(error: error)
                }.catchMap { error -> Response in
                    throw FirestoreError.requestFailed
                }
            }
            return response.future(response)
        })
    }
}

