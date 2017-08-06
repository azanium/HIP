//
//  HPPlayer.swift
//  Hip
//
//  Created by Suhendra Ahmad on 8/6/17.
//  Copyright © 2017 Ainasoft. All rights reserved.
//

import Foundation
import Alamofire
import M3U8Kit

class HPPlayer {
    
    let url: URL!
    
    fileprivate var _playlist: M3U8PlaylistModel!
    var playlist: M3U8PlaylistModel {
        return _playlist
    }
    
    fileprivate var _downloadManager = HPDownloadManager()
    var downloadManager: HPDownloadManager {
        return _downloadManager
    }
    
    init(_ url: URL) {
        self.url = url
    }
    
    func play() {
        do {
            _playlist = try M3U8PlaylistModel(url: self.url)
            print("\(_playlist.segmentNames(for: _playlist.audioPl)!)")
        }
        catch _ {
            print("# Failed to load playlist")
        }
        
        setupDownloadParts()
    }
    
    func setupDownloadParts() {
        let audioPl = _playlist.audioPl
        
        if let segments = audioPl?.segmentList {
            let partCount = segments.count
            print("part Count: \(partCount)")
            
            for index in 0..<partCount {
                if let info = segments.segmentInfo(at: index) {
                    if let url = info.mediaURL(), let offset = info.bytesOffset, let length = info.bytesLength {
                        print("# url: \(url.absoluteString)")
                        
                        HPDownloadManager.shared.addDownload(url, offset: Int(offset)!, length: Int(length)!)
                    }
                }
            }
            
            HPDownloadManager.shared.start({ (finishedTask, totalTask) in
                
                print("Finished task \(finishedTask) of \(totalTask)")
                
            }, { 
                
                print("Download finished")
                
            })
        }
    }
}
