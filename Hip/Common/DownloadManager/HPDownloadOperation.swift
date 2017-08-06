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
    var completionHandler: CompletionHandler?
    
    convenience init(_ url: URL, offset: Int = 0, length: Int = 0) {
        self.init()
        
        self.url = url
        self.offset = offset
        self.length = length
    }

    override func execute() {
        print("# Downloading: \(offset), \(length) => url: \(self.url!.absoluteString)")
        
        let headers = ["Range":"bytes=\(offset)-\(offset+length)"]
        
        /*let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("pig.png")
            
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }

        download(self.url.path, to: destination).response { response in
            print(response)
            
            if response.error == nil, let path = response.destinationURL?.path {
                //let image = UIImage(contentsOfFile: imagePath)
                print("# Saving to.. \(path)")
            }
            self.finish()
        }*/
        
        let request = download(self.url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers) { (tempUrl, response) -> (destinationURL: URL, options: DownloadRequest.DownloadOptions) in
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent("audio_\(self.offset).ts")
            
            print("==> Saving to.. \(fileURL.absoluteString)")
                
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        request.response { (response) in
            DispatchQueue.main.async {
                print("================ Download finished ====================")
            }
            self.finish()
        }
        
  //      let dist = DispatchTime.now() + .seconds(Int(2))
        //DispatchQueue.main.asyncAfter(deadline: dist) {
          //  self.finish()
//            completionHandler?()
//        }
    }    
}
