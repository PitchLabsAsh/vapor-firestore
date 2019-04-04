//
//  FirestoreRequest.swift
//  App
//
//  Created by Ash Thwaites on 02/04/2019.
//


import Foundation
import Vapor
import JWT


public struct ScopeClaim: JWTClaim, ExpressibleByStringLiteral {
    /// The claim's subject's identifier
    public var value: String
    
    /// See Claim.init
    public init(value: String) {
        self.value = value
    }
}

public enum Firestore
{

    public enum Auth
    {
        public struct Payload: JWTPayload {
            
            public var exp: ExpirationClaim
            public var iss: IssuerClaim
            public var aud: AudienceClaim
            public var iat: IssuedAtClaim
            public var scope: ScopeClaim
            
            public init(exp: ExpirationClaim = ExpirationClaim(value: Date(timeIntervalSinceNow: (60 * 15))),
                        iss: IssuerClaim,
                        aud: AudienceClaim = AudienceClaim(value: "https://www.googleapis.com/oauth2/v4/token"),
                        iat: IssuedAtClaim = IssuedAtClaim(value: Date()),
                        scope: ScopeClaim =  ScopeClaim(value: "https://www.googleapis.com/auth/datastore")) {
                self.exp = exp
                self.iss = iss
                self.aud = aud
                self.iat = iat
                self.scope = scope
            }

            public func verify(using signer: JWTSigner) throws {
                try exp.verifyNotExpired()
            }
        }

        
        public struct Request: Content {
            public static let defaultMediaType: MediaType = MediaType.urlEncodedForm
            
            public let grantType: String
            public let assertion: String
            
            enum CodingKeys: String, CodingKey {
                case assertion
                case grantType = "grant_type"
            }
            
            public init(grantType: String, assertion: String) {
                self.grantType = grantType
                self.assertion = assertion
            }
        }
        
        public struct Response: Content {
            public var accessToken: String
            public var tokenType: String
            public var expiresIn: Int
            
            enum CodingKeys: String, CodingKey {
                case accessToken = "access_token"
                case tokenType = "token_type"
                case expiresIn = "expires_in"
            }
        }
    }
    
    
    enum Create
    {
        public struct Request<T: Codable>: Content {
            public let fields: T?
        }
        
        public struct Response<T: Codable>: Content {
        }

    }
    
    enum List
    {
        public struct Request<T: Codable>: Content {
        }

        public struct Response<T: Codable>: Content {
            public let documents: [Document<T>]
            
            public init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                documents = try values.decodeIfPresent( [Document<T>].self, forKey: .documents) ?? [Document<T>]()
            }
        }
        
    }

    
    public struct Document<T: Codable>: Codable {
        public let name: String
        public let createTime: Date
        public let updateTime: Date
        public let fields: T?
        public var id: String { return String(name.split(separator: "/").last ?? "") }
    }
    
    public struct MapValue<T: Codable>: Codable {
        public let mapValue: Firestore.Map<T>
        public init(_ value: T) {
            mapValue = Firestore.Map(fields: value)
        }
    }
    
    public struct Map<T: Codable>: Codable {
        public let fields: T
    }
    
    public struct ArrayValue<T: Codable>: Codable {
        public let arrayValue: Firestore.Array<T>
        public init(_ values: [T]) {
            arrayValue = Firestore.Array(values: values)
        }
    }
    
    public struct Array<T: Codable>: Codable {
        public let values: [T]?
    }
    
    public struct StringValue: Codable {
        public let stringValue: String
        public init(_ value: String) {
            stringValue = value
        }
    }
    
    public struct BooleanValue: Codable {
        public let booleanValue: Bool
        public init(_ value: Bool) {
            booleanValue = value
        }
    }
    
    public struct IntegerValue: Codable {
        private let _integerValue: String
        public var integerValue: Int { return Int(_integerValue) ?? 0 }
        
        enum CodingKeys: String, CodingKey {
            case _integerValue = "integerValue"
        }
        public init(_ value: Int) {
            _integerValue = String(value)
        }
    }
    
    public struct GeoPointValue: Codable {
        public let geoPointValue: GeoPoint
        public init(latitude: Double, longitude: Double) {
            geoPointValue = GeoPoint(latitude: latitude, longitude: longitude)
        }
    }
    
    public struct GeoPoint: Codable {
        public let latitude: Double
        public let longitude: Double
    }
    
    public struct NullValue: Codable {
        public let nullValue = 0
        public init() {}
    }
    
    public struct TimestampValue: Codable {
        public let timestampValue: Date
        public init(_ value: Date) {
            timestampValue = value
        }
    }
    
    public struct ReferenceValue: Codable {
        public let referenceValue: String
        public init(_ value: String) {
            referenceValue = value
        }
    }
    
}


