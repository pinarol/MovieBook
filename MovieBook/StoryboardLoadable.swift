//
//  StoryboardLoadable.swift
//  MovieBook
//
//  Created by Pinar Olguc.
//  Copyright © 2022 . All rights reserved.
//

import Foundation
import UIKit

/// Protocol that provides UIViewController's 
/// Storyboard name and ID
public protocol StoryboardLoadable {
    
    /// Storyboard name including this UIViewController
    static var storyboardName: String { get }
    
    /// Storyboard ID of this UIViewController
    /// Default implementation returns class name
    static var storyBoardID: String { get }
}

public extension StoryboardLoadable {
    
    static var storyBoardID: String { return String(describing: Self.self) }
    
    /// Instantiates the UIViewController
    ///
    /// - Returns: new UIViewController instance
    static func instantiate() -> Self {
        return UIStoryboard(name: storyboardName, bundle: Bundle.main).instantiateViewController(withIdentifier: Self.storyBoardID) as! Self
    }
}
