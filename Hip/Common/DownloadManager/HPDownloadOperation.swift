//
//  HPDownloadOperation.swift
//  Hip
//
//  Created by Suhendra Ahmad on 8/5/17.
//  Copyright © 2017 Ainasoft. All rights reserved.
//

import UIKit
import Alamofire

class HPDownloadOperation: AsyncOperation {
    
    typealias CompletionHandler = ()->Void
    
    var url: URL!
    var offset: Int = 0
    var length: Int = 0
    var targetFilename: String = ""
    var completionHandler: CompletionHandler?
    
    convenience init(_ url: URL, offset: Int = 0, length: Int = 0, targetFilename: String = "audio.ts") {
        self.init()
        
        self.url = url
        self.offset = offset
        self.length = length
        self.targetFilename = targetFilename
    }

    override func execute() {
        print("# Downloading: \(offset), \(length) => url: \(self.url!.absoluteString)")
        
        let headers = ["Range":"bytes=\(offset)-\(offset+length)"]
        
        let request = download(self.url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) { (tempUrl, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(self.targetFilename)
            
            print("==> Saving to.. \(fileURL.absoluteString)")
                
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        request.response { (response) in
            DispatchQueue.main.async {
            }
            self.finish()
        }
        
    }
}
