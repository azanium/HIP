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

protocol HPPlayerDelegate {
    
    func playerProgress(currentTask: Int, totalTask: Int)
    func playerAudioDownloaded(mediaPlaylist: String)
    
}

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
    
    var delegate: HPPlayerDelegate?
    
    init(_ url: URL) {
        self.url = url
    }
    
    func play() {
        do {
            _playlist = try M3U8PlaylistModel(url: self.url)
            print("\(_playlist.segmentNames(for: _playlist.audioPl)!)")
            print("==> \(_playlist.audioPl.originalURL.lastPathComponent)")
        }
        catch _ {
            print("# Failed to load playlist")
        }
        
        setupDownloadParts()
    }
    
    func setupDownloadParts() {
        let audioPl = _playlist.audioPl
        let targetMediaPlaylistFile = HPDownloadManager.localDestination.appendingPathComponent((audioPl?.originalURL.lastPathComponent)!)
        
        // Cache the playlist
        do {
            try audioPl?.originalText.write(to: targetMediaPlaylistFile, atomically: true, encoding: String.Encoding.utf8)
        }
        catch let err {
            print("Failed to save file: \(err) ")
            return
        }
        
        // Build the segment parts
        if let segments = audioPl?.segmentList {
            let partCount = segments.count
            print("part Count: \(partCount)")
            
            var targetParts = [URL]()
            var targetAudioFile = "audio.ts"
            
            for index in 0..<partCount {
                if let info = segments.segmentInfo(at: index) {
                    if let url = info.mediaURL(), let offset = info.bytesOffset, let length = info.bytesLength {
                    
                        // Target single audio file
                        targetAudioFile = url.lastPathComponent
                        
                        // Temporary part file
                        let targetFilename = "part_\(offset)_\(length).ts"
                        
                        targetParts += [HPDownloadManager.localDestination.appendingPathComponent(targetFilename)]
                        
                        HPDownloadManager.shared.addDownload(url, offset: Int(offset)!, length: Int(length)!, targetFilename: targetFilename)
                    }
                }
            }
            
            HPDownloadManager.shared.start({ (finishedTask, totalTask) in
                
                DispatchQueue.main.async {
                    self.delegate?.playerProgress(currentTask: finishedTask, totalTask: totalTask)
                }
                
            }, { 
                
                print("Download finished: \(targetParts)")
                
                DispatchQueue.global().async {
                    do {
                        try FileManager.default.merge(files: targetParts, to: HPDownloadManager.localDestination.appendingPathComponent(targetAudioFile))
                    }
                    catch let err {
                        print("* Merge failed: \(err)")
                    }
                    
                    for file in targetParts {
                        do {
                            try FileManager.default.removeItem(at: file)
                        }
                        catch let err {
                            print("* Failed to delete: \(err)")
                        }
                    }
                    
                    DispatchQueue.main.async {
                        
                        self.delegate?.playerAudioDownloaded(mediaPlaylist: (audioPl?.originalURL.lastPathComponent)!)
                        
                    }
                }
                
                
            })
        }
    }
}
