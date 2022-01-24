//
//  MovieSearchNetworkModels.swift
//  MovieBook
//
//  Created by Pinar Olguc.
//  Copyright © 2022 . All rights reserved.
//

import Foundation
import Alamofire

struct MovieSearchError: Error {
    let message: String
}

struct MovieSearchRequest: Request {
    let query: String
    var url: String {
        return "http://api.themoviedb.org/3/search/movie"
    }
    var httpMethod: HTTPMethod { return .get }
    
    var queryParameters: [String : String]? {
        return ["api_key" : "2696829a81b1b5827d515ff121700838",
                "query" : query]
    }
    
    init(query: String) {
        self.query = query
    }
}

struct MovieSummaryNetworkModel: Decodable {
    
    enum Keys: String, CodingKey {
       case poster_path
       case original_title
       case release_date
       case overview
    }
    
    var poster: String?
    var name: String?
    var releaseDate: String?
    var overview: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Keys.self)
        self.poster = try? container.decode(String.self, forKey: .poster_path)
        self.name = try? container.decode(String.self, forKey: .original_title)
        self.releaseDate = try? container.decode(String.self, forKey: .release_date)
        self.overview = try? container.decode(String.self, forKey: .overview)
    }
}

class MovieSearchResponse: BaseResponse {
    
    var movies: [MovieSummaryNetworkModel]?

    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        movies = try container.decode([MovieSummaryNetworkModel].self, forKey: .results)
    }
}
