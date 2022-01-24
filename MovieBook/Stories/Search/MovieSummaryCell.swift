//
//  MovieSummaryCell.swift
//  MovieBook
//
//  Created by Pinar Olguc.
//  Copyright © 2022 . All rights reserved.
//

import Foundation
import UIKit

class MovieSummaryCell: UITableViewCell {
    
    static let reuseIdentifier = "MovieSummaryCell"
    
    fileprivate let posterImageBaseUrl = "http://image.tmdb.org/t/p/w92"
    @IBOutlet fileprivate weak var posterImageView: UIImageView!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    @IBOutlet fileprivate weak var releaseDateLabel: UILabel!
    @IBOutlet fileprivate weak var overviewLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textAlignment = .left
        releaseDateLabel.textAlignment = .right
        overviewLabel.textAlignment = .right
        overviewLabel.numberOfLines = 0
        overviewLabel.font = UIFont(name: "Arial", size: 12.0)
        posterImageView.contentMode = .scaleAspectFit
        selectionStyle = .none
    }
    
    func update(with movie: MovieSummary) {
        posterImageView.image = nil
        titleLabel.text = movie.name
        releaseDateLabel.text = movie.releaseDate
        overviewLabel.text = movie.overview
        
        if let url = URL(string: posterImageBaseUrl + movie.posterUrl) {
            getImage(from: url) { [weak self] (image) in
                guard let strongSelf = self else { return }
                if let myImage = image {
                    strongSelf.posterImageView.image = myImage
                } else {
                    //TODO: set some placeholder image
                }
            }
        }
    }
}
