//
//  MoviewSearchPresentationModels.swift
//  MovieBook
//
//  Created by Pinar Olguc.
//  Copyright © 2022. All rights reserved.
//

import Foundation
import Combine

/// struct for MovieSummary to display
struct MovieSummary {
    let posterUrl: String
    let name: String
    let releaseDate: String
    let overview: String
}

/// List of changes for MovieSearch
///
/// - querySucceeded: Indicates that query found results with success.
///
/// - queryFailed: Indicates that query didn't find any results or
///                some other failure happened. Error message is 
///                associated
enum MovieSearchChange {
    case querySucceeded
    case queryFailed(errorMessage: String)
}

/// Protocol for holding states of MovieSearch
protocol MovieSearchState {
    /// Movies of search result
    var movies: [MovieSummary] { get }
    /// Most recent successful query
    var mostRecentSuccessfulQuery: String? { get set }
}

protocol MovieSearchViewModelDelegate: AnyObject {
    func viewModelDidChange(change: MovieSearchChange)
}

/// Protocol for operations and state of MovieSearch
protocol MovieSearchViewModel {
    /// state of MovieSearch
    var state: MovieSearchState { get set }
    
    /// suggested options for search
    var suggestedOptions: [String]? { get }
        
    /// Method for querying. Result is expected to be passed by 
    /// MovieSearchState in form of MovieSearchChange.
    ///
    /// - Parameter queryString: string to use in query to search
    ///   among movie titles.
    func query(by queryString: String?)
    
    var onMoviesUpdated: (([MovieSummary]) -> Void)? { get set }
    
    var onMovieSearchError: ((String) -> Void)? { get set }
}
