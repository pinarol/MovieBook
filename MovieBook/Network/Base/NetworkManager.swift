//
//  NetworkManager.swift
//  MovieBook
//
//  Created by Pinar Olguc.
//  Copyright © 2022. All rights reserved.
//

import Foundation
import Alamofire
import Combine

/// List of generic errors
enum GenericNetworkErrors {
    static let message = "Something went wrong. Please try again later."
}

/// Protocol for all HTTP Requests to conform
protocol Request {
    var url: String { get }
    var httpMethod: HTTPMethod { get }
    var bodyParameters: [String: Any]? { get }
    var queryParameters: [String: String]? { get }
}

extension Request {
    var bodyParameters: [String: Any]? { return nil }
    var queryParameters: [String: String]? { return nil }
    
    var escapedUrl: String {
        var result = ""
        if let parms = queryParameters {
            for parm in parms.enumerated() {
                if parm.offset != 0 {
                    result = result + "&"
                }
                result = result + (parm.element.key.escaped + "=" + parm.element.value.escaped)
            }
        }
        return url + (result == "" ? "" : "?" + result)
    }
}

/// Protocol for all json HTTP responses to conform
protocol Response: Decodable {
}

class BaseResponse: Response {
    
    enum Keys: String, CodingKey {
        case total_pages
        case total_results
        case page
    }

    var totalPages: Int = 0
    var totalResults: Int = 0
    var page: Int = 0
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        totalPages = try container.decode(Int.self, forKey: .total_pages)
        totalResults = try container.decode(Int.self, forKey: .total_results)
        page = try container.decode(Int.self, forKey: .page)
    }
}

enum CodingKeys: String, CodingKey {
   case status_code
   case status_message
   case success
   case results
}

/// NetworkRequestResult defines possible network results
///
/// - success: success result including the response data
/// - fail: fa'lure result including the network error
enum NetworkRequestResult<T: Response> {
    case success(T)
    case fail(NetworkErrorType)
}

/// All types of network errors will be added here
/// In case we want to handle them differently
enum NetworkErrorType: Error {
    case noInternet(NetworkError)
    case serviceUnavailable(NetworkError)
    case sessionExpired(NetworkError)
}


/// Struct for defining a NetworkError
struct NetworkError {
    var error: (message: String, code: Int)
    var statusCode: Int
}

/// Protocol for defining operations to make a network request
protocol NetworkManager {
    
    /// Makes an async network request and dispatches the response to main queue
    ///
    /// - Parameters:
    ///   - request: request to make
    ///   - completion: completion that provodides result
    func request<R: Response>(with request: Request) -> AnyPublisher<R, NetworkErrorType>
}

/// Class for defining operations to make a network request
class DefaultNetworkManager: NetworkManager {
    
    /// Makes an async network request and dispatches the response to main queue
    ///
    /// - Parameters:
    ///   - request: request to make
    func request<R: Response>(with request: Request) -> AnyPublisher<R, NetworkErrorType> {
        print("URL Request: \(request.escapedUrl)")
        let publisher: (AnyPublisher<R, NetworkErrorType>) =
        AF.request(request.escapedUrl,
                   method: request.httpMethod,
                   parameters: request.bodyParameters)
            .validate(statusCode: [200, 201, 400])
            .publishDecodable(type: R.self)
            .value()
            .mapError { afError in
                return NetworkErrorType.serviceUnavailable(.init(error: (message: GenericNetworkErrors.message, code: afError.responseCode ?? 0), statusCode: afError.responseCode ?? 400))
            }
            .eraseToAnyPublisher()
        return publisher
    }
}
