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
        let sendReq: Future<String> = try self.request.getToken(req: req)
        return sendReq
    }
}
