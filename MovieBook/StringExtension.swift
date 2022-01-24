//
//  StringExtension.swift
//  MovieBook
//
//  Created by Pinar Olguc on 17/07/2022.
//  Copyright © 2022 Monitise. All rights reserved.
//

import Foundation

extension String {
    
    /// Escape "!*'();:@&=+$,/?%#[] " chars with PercentEncoding
    var escaped: String {
        let allowedCharacterSet = (CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted)
        if let escapedString = self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) {
            return escapedString
        }
        return self
    }

}
