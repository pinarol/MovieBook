//
//  MovieSearchViewModel.swift
//  MovieBook
//
//  Created by Pinar Olguc.
//  Copyright © 2022. All rights reserved.
//

import Foundation
import Combine

class DefaultMovieSearchViewModel: MovieSearchViewModel {

    enum Const {
        static let suggestedOptionsKey = "MovieSearchSuggestedOptionsKey"
        static let maxSuggestions = 10
    }
    var networkManager: NetworkManager = DefaultNetworkManager()
    var userDefaults: UserDefaultsManager = DefaultUserDefaultsManager.shared
    weak var delegate: MovieSearchViewModelDelegate?
    var _state = State()
    
    struct State: MovieSearchState {
        var mostRecentSuccessfulQuery: String?
        var movies: [MovieSummary] = []
    }
    
    var suggestedOptions: [String]? {
        return userDefaults.array(forKey: Const.suggestedOptionsKey)
    }
    
    var onMoviesUpdated: (([MovieSummary]) -> Void)? = nil
    var onMovieSearchError: ((String) -> Void)? = nil
    
    private var tasks: Set<AnyCancellable> = []

    init() { }
    
    func query(by queryString: String?) {
        guard let queryString = queryString else { return }
        let request = MovieSearchRequest(query: queryString)
        networkManager.request(with: request)
            .receive(on: RunLoop.main)
            .mapError({ errorType -> MovieSearchError in
                switch errorType {
                case .serviceUnavailable(let error),
                     .noInternet(let error),
                     .sessionExpired(let error):
                    return MovieSearchError(message: error.error.message)
                }
            })
            .map({ [weak self] (response: MovieSearchResponse) -> [MovieSummary] in
                var movies: [MovieSummary] = []
                guard let responseMovies = response.movies else { return movies }
                for movie in responseMovies {
                    movies.append(MovieSummary(posterUrl: movie.poster ?? "",
                                               name: movie.name ?? "",
                                               releaseDate: movie.releaseDate ?? "",
                                               overview: movie.overview ?? ""))
                }
                guard let strongSelf = self else { return [] }
                strongSelf._state.movies = movies
                strongSelf._state.mostRecentSuccessfulQuery = queryString
                strongSelf.persist(suggestedSearch: queryString)

                return movies
            })
            .eraseToAnyPublisher()
            .sink { [weak self] result in
                switch result {
                case .failure(let movieSearchError):
                    self?.onMovieSearchError?(movieSearchError.message)
                case .finished:
                    break
                }
            } receiveValue: { [weak self] movies in
                self?.onMoviesUpdated?(movies)
            }
            .store(in: &tasks)
    }
    
    func persist(suggestedSearch: String) {
        var result: [String] = []
        if let savedSearches: [String] = userDefaults.array(forKey: Const.suggestedOptionsKey) {
            result = savedSearches
        }

        if let index = result.firstIndex(of: suggestedSearch) {
            result.remove(at: index)
        }
        
        result.insert(suggestedSearch, at: 0)

        if result.count > Const.maxSuggestions {
            result = Array(result.prefix(upTo: Const.maxSuggestions))
        }
        userDefaults.set(result, forKey: Const.suggestedOptionsKey)
    }
}

extension DefaultMovieSearchViewModel {

    //In order to conform to MovieSearchViewModel
    var state: MovieSearchState {
        get { return _state }
        set {
            if let myState = newValue as? DefaultMovieSearchViewModel.State {
                _state = myState
            }
        }
    }
}
