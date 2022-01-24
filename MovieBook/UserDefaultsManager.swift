//
//  UserDefaultsManager.swift
//  MovieBook
//
//  Created by Pinar Olguc.
//  Copyright © 2022 . All rights reserved.
//

import Foundation

/// Protocol for defining user default operations
protocol UserDefaultsManager {
    
    /// Sets given value to user defaults
    ///
    /// - Parameters:
    ///   - value: value to set
    ///   - defaultName: key name for the value
    func set(_ value: Any?, forKey defaultName: String)
    
    /// Gets array of given type T
    ///
    /// - Parameter defaultName: key name for the value
    /// - Returns: Array of given type T
    func array<T>(forKey defaultName: String) -> [T]?
}

/// The DefaultUserDefaultsManager provides an interface for 
/// interacting with the defaults system.
class DefaultUserDefaultsManager: UserDefaultsManager {
    
    /// Shared instance
    static let shared = DefaultUserDefaultsManager()
    
    private init() { }
    
    /// Sets given value to user defaults
    ///
    /// - Parameters:
    ///   - value: value to set
    ///   - defaultName: key name for the value
    func set(_ value: Any?, forKey defaultName: String) {
        UserDefaults.standard.set(value, forKey: defaultName)
    }
    
    /// Gets array of given type T
    ///
    /// - Parameter defaultName: key name for the value
    /// - Returns: Array of given type T
    func array<T>(forKey defaultName: String) -> [T]? {
        if let result = UserDefaults.standard.array(forKey: defaultName) as? [T] {
            return result
        }
        return nil
    }
}
