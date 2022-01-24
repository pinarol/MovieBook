//
//  UIViewControllerExtension.swift
//  MovieBook
//
//  Created by Pinar Olguc.
//  Copyright © 2022. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    /// Shows a new UIAlertController on this UIViewController
    ///
    /// - Parameters:
    ///   - title: title of UIAlertController
    ///   - message: message of UIAlertController
    ///   - actionTitle: action title of UIAlertController
    func showAlert(with title: String = "Error",
                   message: String,
                   actionTitle: String = "OK") {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle,
                                   style: .cancel,
                                   handler: { (action) in
            alert.dismiss(animated: false, completion: nil)
        })
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}
