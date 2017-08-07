//
//  String.swift
//  Hip
//
//  Created by Suhendra Ahmad on 8/7/17.
//  Copyright © 2017 Ainasoft. All rights reserved.
//

import Foundation

extension String {
    var length: Int {
        return self.characters.count
    }
    
    func substring(_ from: Int) -> String {
        return self.substring(from: self.characters.index(self.startIndex, offsetBy: from))
    }
}
