//
//  HPDownloadOperation.swift
//  Hip
//
//  Created by Suhendra Ahmad on 8/5/17.
//  Copyright © 2017 Ainasoft. All rights reserved.
//

import UIKit

class HPDownloadOperation: AsyncOperation {
    
    var url: URL!
    
    convenience init(_ url: URL) {
        self.init()
        
        self.url = url
    }

    override func execute() {
        print("#op start: \(self.url)")
        
        let dist = DispatchTime.now() + .seconds(Int(2))
        DispatchQueue.main.asyncAfter(deadline: dist) {
            self.finish()
        }
    }    
}
