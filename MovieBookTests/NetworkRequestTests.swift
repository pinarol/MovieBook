//
//  NetworkRequestTests.swift
//  MovieBook
//
//  Created by Pinar Olguc on 17/07/2022.
//  Copyright © 2022 Monitise. All rights reserved.
//

import XCTest
@testable import MovieBook
import Alamofire

class NetworkRequestTests: XCTestCase {
    
    private struct MockRequest: Request {
        var url: String { return "https://www.google.com.tr/search" }
        var httpMethod: HTTPMethod { return .get }
        var queryParameters: [String : String]?
    }
    
    func testExample() {
        var mockRequest = MockRequest()
        
        mockRequest.queryParameters = ["q": "soli taire", "oq":"sol"]
        XCTAssertTrue(mockRequest.escapedUrl == "https://www.google.com.tr/search?q=soli%20taire&oq=sol")
        
        mockRequest.queryParameters = ["q": "!*'();:@&=+$,/?%#[]", "oq":"sol"]
        XCTAssertTrue(mockRequest.escapedUrl == "https://www.google.com.tr/search?q=%21%2A%27%28%29%3B%3A%40%26%3D%2B%24%2C%2F%3F%25%23%5B%5D&oq=sol")
        
        mockRequest.queryParameters = nil
        XCTAssertTrue(mockRequest.escapedUrl == "https://www.google.com.tr/search")
    }
    
}
