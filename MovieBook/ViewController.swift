//
//  ViewController.swift
//  MovieBook
//
//  Created by Pinar Olguc.
//  Copyright © 2022 . All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func searchMoviesButtonTapped(_ sender: Any) {
        let nextVC = MovieSearchViewController.instantiate()
        nextVC.viewModel = DefaultMovieSearchViewModel()
        let navC = UINavigationController(rootViewController: nextVC)
        self.present(navC, animated: true, completion: nil)
    }
}

