//
//  MovieSearchViewModelTests.swift
//  MovieBook
//
//  Created by Pinar Olguc on 17/07/2022.
//  Copyright © 2022 Monitise. All rights reserved.
//

import Foundation

import XCTest
import Combine
@testable import MovieBook

class MovieSearchViewModelTests: XCTestCase {
    
    typealias ViewModel = DefaultMovieSearchViewModel
    typealias Change    = MovieSearchChange
    
    private class Box: MovieSearchViewModelDelegate {
        var viewModel: ViewModel? {
            didSet {
                viewModel?.delegate = self
            }
        }
        var changes: [Change] = []
        
        func viewModelDidChange(change: MovieSearchChange) {
            self.changes.append(change)
        }
        
        init() {
        }
    }
    
    
    fileprivate struct MockError: Error {
        static let code = 333
        static let message = "Data couldn't be fetched"
    }
    
    fileprivate class MockUserDefaultsManager: UserDefaultsManager {
    
        var array: [String] = []
        
        func set(_ value: Any?, forKey defaultName: String) {
            if let arr = value as? [String] {
                array = arr
            }
        }
        
        func array<T>(forKey defaultName: String) -> [T]? {
            if let result = array as? [T] {
                return result
            }
            return nil
        }
    }
    
    fileprivate class MockSearchNetworkManager: NetworkManager {
        
        func request<R>(with request: Request) -> AnyPublisher<R, NetworkErrorType> where R : Response {
            
        }
        
        
        enum Result {
            case success(json: NSDictionary)
            case fail
        }
        let resultType: Result
        
        init(_ result: Result) {
            self.resultType = result
        }
        
        func request<MovieSearchResponse>(with request: Request, completion: @escaping (NetworkRequestResult<MovieSearchResponse>) -> Void) {
            switch resultType {
            case .success(let json):
                let responseData = MovieSearchResponse(with: json)
                let result: NetworkRequestResult<MovieSearchResponse> = .success(responseData)
                completion(result)

            case .fail:
                let result: NetworkRequestResult<MovieSearchResponse> =
                    .fail(NetworkErrorType.serviceUnavailable(NetworkError(error: (message: MockError.message, code: MockError.code),
                                                                           statusCode: MockError.code)))
                completion(result)
            }
        }
    }
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSuccessResult() {
        let box = Box()
        box.viewModel = DefaultMovieSearchViewModel()
        
        let successJson: [String: Any] =
            ["results" :
                [
                    ["poster_path": "path1",
                     "original_title":"title1",
                    "release_date":"date1",
                    "overview":"overview1"],
                    
                    ["poster_path": "path2",
                     "original_title":"title2",
                     "release_date":"date2",
                    "overview":"overview2"]
                ]
            ]
        
        box.viewModel?.networkManager =
            MockSearchNetworkManager(.success(json: NSDictionary(dictionary: successJson)))
        box.viewModel?.userDefaults = MockUserDefaultsManager()
        
        box.viewModel?.query(by: "query1")
        
        XCTAssertTrue(box.changes[0] == MovieSearchChange.querySucceeded)
        
        XCTAssertTrue(box.viewModel?.state.movies![0].posterUrl == "path1")
        XCTAssertTrue(box.viewModel?.state.movies![0].name == "title1")
        XCTAssertTrue(box.viewModel?.state.movies![0].releaseDate == "date1")
        XCTAssertTrue(box.viewModel?.state.movies![0].overview == "overview1")
        
        XCTAssertTrue(box.viewModel?.state.movies![1].posterUrl == "path2")
        XCTAssertTrue(box.viewModel?.state.movies![1].name == "title2")
        XCTAssertTrue(box.viewModel?.state.movies![1].releaseDate == "date2")
        XCTAssertTrue(box.viewModel?.state.movies![1].overview == "overview2")

        XCTAssertTrue(box.viewModel?.suggestedOptions![0] == "query1")
        
        box.viewModel?.query(by: "query2")
        
        XCTAssertTrue(box.viewModel?.suggestedOptions![0] == "query2")
        XCTAssertTrue(box.viewModel?.suggestedOptions![1] == "query1")
        
        box.viewModel?.query(by: "query2")
        box.viewModel?.query(by: "query3")
        box.viewModel?.query(by: "query4")
        box.viewModel?.query(by: "query5")
        box.viewModel?.query(by: "query6")
        box.viewModel?.query(by: "query7")
        box.viewModel?.query(by: "query8")
        box.viewModel?.query(by: "query9")
        box.viewModel?.query(by: "query10")
        box.viewModel?.query(by: "query11")
        
        XCTAssertTrue(box.viewModel?.suggestedOptions![0] == "query11")
        XCTAssertTrue(box.viewModel?.suggestedOptions![1] == "query10")
        XCTAssertTrue(box.viewModel?.state.mostRecentSuccessfulQuery == "query11")
        XCTAssertTrue(box.viewModel?.suggestedOptions!.count == 10)
    }
    
    func testEmptySuccessResult() {
        let box = Box()
        box.viewModel = DefaultMovieSearchViewModel()
        
        let successJson: [String: Any] = ["results" :[]]
        
        box.viewModel?.networkManager =
            MockSearchNetworkManager(.success(json: NSDictionary(dictionary: successJson)))
        box.viewModel?.userDefaults = MockUserDefaultsManager()
        
        box.viewModel?.query(by: "query1")
        
        XCTAssertTrue(box.changes[0] == MovieSearchChange.queryFailed(errorMessage: "No results"))
        XCTAssertTrue((box.viewModel?.suggestedOptions?.count ?? 0) == 0)
        XCTAssertTrue((box.viewModel?.state.movies?.count ?? 0) == 0)
    }
    
    func testNetworkFailResult() {
        let box = Box()
        box.viewModel = DefaultMovieSearchViewModel()
        box.viewModel?.networkManager = MockSearchNetworkManager(.fail)
        box.viewModel?.userDefaults = MockUserDefaultsManager()
        
        box.viewModel?.query(by: "query1")
        
        XCTAssertTrue(box.changes[0] == MovieSearchChange.queryFailed(errorMessage: MockError.message))
        XCTAssertTrue((box.viewModel?.suggestedOptions?.count ?? 0) == 0)
        XCTAssertTrue((box.viewModel?.state.movies?.count ?? 0) == 0)

    }
}

extension MovieSearchChange: Equatable, RawRepresentable {
    
    typealias RawValue = Int
    
    init?(rawValue: Int) {
        switch rawValue {
        case 1:
            self = .querySucceeded
        case 2:
            self = .queryFailed(errorMessage: "")
        default:
            return nil
        }
    }
    
    var rawValue: Int {
        switch self {
        case .querySucceeded:
            return 1
        case .queryFailed(_):
            return 2
        }
    }
    
    static func ==(lhs: MovieSearchChange, rhs: MovieSearchChange) -> Bool {
        switch (lhs, rhs) {
        case (.queryFailed(let errorMessage1), .queryFailed(let errorMessage2)):
            return errorMessage1 == errorMessage2
        default: break
        }
        return lhs.rawValue == rhs.rawValue
    }
}
