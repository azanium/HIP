//
//  HPDownloadManager.swift
//  Hip
//
//  Created by Suhendra Ahmad on 8/5/17.
//  Copyright © 2017 Ainasoft. All rights reserved.
//

import UIKit

class HPDownloadManager : NSObject {

    typealias DownloadCompletionHandler = ()->Void
    typealias ProgressHandler = (Int, Int)->Void
    
    var completionHandler: DownloadCompletionHandler?
    var progressHandler: ProgressHandler?
    
    fileprivate var downloadOperations = [HPDownloadOperation]()
    fileprivate var _totalOperations = 0
    
    static var localDestination: URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        return documentsURL
    }
    
    var totalOperations: Int {
        return _totalOperations
    }
    
    static let shared: HPDownloadManager = {
        return HPDownloadManager()
    }()
    
    fileprivate var downloadQueue: OperationQueue = OperationQueue()
    
    override init() {
        super.init()
    }
    
    deinit {}
    
    fileprivate func setupQueue() {
        downloadQueue = OperationQueue()
        downloadQueue.maxConcurrentOperationCount = 2
        downloadQueue.name = "MaxQ"
        
        downloadQueue.addObserver(self, forKeyPath: "operationCount", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    fileprivate func disposeQueue() {
        downloadQueue.removeObserver(self, forKeyPath: "operationCount")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard let _ = object as? OperationQueue, keyPath == "operationCount" else {
            return
        }
        
        if let opCount = change?[.newKey] as? NSNumber {
            
            if opCount.intValue > 0 {
                DispatchQueue.main.async { [weak self] in
                    if let totalOp = self?._totalOperations {
                        self?.progressHandler?(totalOp - opCount.intValue + 1, totalOp)
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    self._totalOperations = 0
                    self.disposeQueue()
                    self.completionHandler?()
                }
            }
        }
        
    }
    
    func addDownload(_ url: URL, offset: Int = 0, length: Int = 0, targetFilename: String = "audio.ts") {
        let operation = HPDownloadOperation(url, offset: offset, length: length, targetFilename: targetFilename)
        
        downloadOperations.append(operation)
        
        _totalOperations = downloadOperations.count
    }
    
    func start(_ progressHandler: ProgressHandler? = nil, _ completionHandler: DownloadCompletionHandler? = nil) {
        setupQueue()
        
        self.progressHandler = progressHandler
        self.completionHandler = completionHandler
        
        downloadQueue.addOperations(downloadOperations, waitUntilFinished: false)
    }
}
