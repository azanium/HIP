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

protocol HPStreamerDelegate {
    
    func streamerProgress(currentTask: Int, totalTask: Int)
    func streamerAudioDownloaded(mediaPlaylist: String, audioFile: String)
    
}

class HPStreamer {
    
    // MARK: - MemVars & Props
    
    let url: URL!
    
    fileprivate var _playlist: M3U8PlaylistModel!
    var playlist: M3U8PlaylistModel {
        return _playlist
    }
    
    var delegate: HPStreamerDelegate?
    
    // MARK: - Init
    
    init(_ url: URL) {
        self.url = url
    }
    
    // MARK: - Methods
    
    func loadAsync(_ delegate: HPStreamerDelegate? = nil) {
        
        self.delegate = delegate
        
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
    
    // Build the download parts from playlist and setup download operations based on it
    
    func setupDownloadParts() {
        guard let audioPl = _playlist.audioPl else {
            return
        }
        
        let targetMediaPlaylistFile = HPDownloadManager.localDestination.appendingPathComponent(audioPl.originalURL.lastPathComponent)
        
        // Cache the playlist
        do {
            try audioPl.originalText.write(to: targetMediaPlaylistFile, atomically: true, encoding: String.Encoding.utf8)
        }
        catch let err {
            print("* Failed to save media manifest: \(err) ")
            return
        }
        
        // Build the segment parts
        if let segments = audioPl.segmentList {
            
            // Get our ts parts count
            let partCount = segments.count
            
            print("# Parts Count: \(partCount)")
            
            // Cache the TS parts into urls
            var targetParts = [URL]()
            
            // Default single concatenated file
            var targetAudioFile = "audio.ts"
            
            for index in 0..<partCount {
                
                // Get the segment
                if let info = segments.segmentInfo(at: index) {
                    
                    // Fetch the mediaURL, length and offset
                    if let url = info.mediaURL(), let offset = info.bytesOffset, let length = info.bytesLength {
                    
                        // Target single audio file
                        targetAudioFile = url.lastPathComponent
                        
                        // Temporary part file
                        let targetFilename = "part_\(offset)_\(length).ts"
                        
                        // Append the target file urls
                        targetParts += [HPDownloadManager.localDestination.appendingPathComponent(targetFilename)]
                        
                        // Create download operation
                        HPDownloadManager.shared.addDownload(url, offset: Int(offset)!, length: Int(length)!, targetFilename: targetFilename)
                    }
                }
            }
            
            HPDownloadManager.shared.start({ (finishedTask, totalTask) in
                
                DispatchQueue.main.async {
                    self.delegate?.streamerProgress(currentTask: finishedTask, totalTask: totalTask)
                }
                
            }, { 
                
                print("# Download finished: \(targetParts)")
                
                // Do TS file merge in the background
                DispatchQueue.global().async {
                    do {
                        try FileManager.default.merge(files: targetParts, to: HPDownloadManager.localDestination.appendingPathComponent(targetAudioFile), chunkSize: 1000)
                    }
                    catch let err {
                        print("* Merge failed: \(err)")
                    }
                    
                    // We now have merged TS file, delete all the TS parts
                    for file in targetParts {
                        do {
                            try FileManager.default.removeItem(at: file)
                        }
                        catch let err {
                            print("* Failed to delete: \(err)")
                        }
                    }
                    
                    // Inform the delegate, we are now have the whole media
                    DispatchQueue.main.async {
                        
                        self.delegate?.streamerAudioDownloaded(mediaPlaylist: audioPl.originalURL.lastPathComponent, audioFile: targetAudioFile)
                        
                    }
                }
                
                
            })
        }
    }
}
