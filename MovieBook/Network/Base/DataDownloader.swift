//
//  DataDownloader.swift
//  MovieBook
//
//  Created by Pinar Olguc.
//  Copyright © 2022 . All rights reserved.
//

import Foundation
import UIKit

/// Downloads data asyncly from given url
///
/// - Parameters:
///   - url: url
///   - completion: closure to call when download ends
func getDataFromUrl(url: URL, completion: @escaping (
    _ data: Data?,
    _ response: URLResponse?,
    _ error: Error?) -> Void) {
    URLSession.shared.dataTask(with: url) {
        (data, response, error) in
            completion(data, response, error)
        }.resume()
}

/// Downloads image asyncly from given url.
/// Dispatches the result to main url.
///
/// - Parameters:
///   - url: url
///   - completion: closure to call when download ends
func getImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
    getDataFromUrl(url: url) { (data, response, error)  in
        guard let data = data, error == nil else {
            completion(nil)
            return
        }
        DispatchQueue.main.async() {
            completion(UIImage(data: data))
        }
    }
}
