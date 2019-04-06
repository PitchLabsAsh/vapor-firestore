import Foundation


struct FirestoreErrorResponse: Codable {
    struct FirestoreErrorResponseBody: Codable {
        let code: Int
        let message: String
        let status: String
    }
    
    let error : FirestoreErrorResponseBody
}

enum FirestoreError: Error {
    case requestFailed
    case signing
    case parseFailed(data: String)
    case response(error: FirestoreErrorResponse)
}
