//
//  HPPlayer.swift
//  Hip
//
//  Created by Suhendra Ahmad on 8/7/17.
//  Copyright © 2017 Ainasoft. All rights reserved.
//

import UIKit
import AVFoundation
import GCDWebServer

enum HPPlayerState {
    case uninitialized
    case fetching
    case playing
    case paused
    case completed
}

protocol HPPlayerDelegate {
    
    func playerStreamProgress(finishedStream: Int, totalStreams: Int)
    
}

class HPPlayer {
    
    // MARK: - MemVars & Props
    fileprivate var webServer = GCDWebServer()
    
    // Media Url
    var url: URL!
    
    // Assets
    var asset: AVURLAsset!
    var playerItem: AVPlayerItem!
    var player: AVPlayer!
    
    fileprivate var _playerState = HPPlayerState.uninitialized
    var playerState: HPPlayerState {
        return _playerState
    }
    
    fileprivate var streamer: HPStreamer!
    
    var delegate: HPPlayerDelegate?
    
    // MARK: - Init
    
    init(_ url: URL) {
        self.url = url
        
        // Spawn a web server
        setupWebServer()
        
        streamer = HPStreamer(url)
    }
    
    // MARK: - Methods
    
    func setupWebServer() {
        let docUrl = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)[0]
        
        webServer.addGETHandler(forBasePath: "/", directoryPath: docUrl.path, indexFilename: nil, cacheAge: 0, allowRangeRequests: true)
        webServer.start(withPort: 8080, bonjourName: nil)
    }
    
    func loadMedia() {
        streamer.loadAsync(self)
    }
}

extension HPPlayer : HPStreamerDelegate {
    
    func streamerProgress(currentTask: Int, totalTask: Int) {
        
    }
    
    func streamerAudioDownloaded(mediaPlaylist: String) {
        setupPlayer(mediaPlaylist: mediaPlaylist)
    }
    
    func setupPlayer(mediaPlaylist: String) {
        let url = URL(string: "http://127.0.0.1:8080/\(mediaPlaylist)")!
        
        print("Play: \(url.path)")
        
        asset = AVURLAsset(url: url, options: nil)
        let trackKey = "tracks"
        
        asset.loadValuesAsynchronously(forKeys: [trackKey]) {
            
            DispatchQueue.main.async() {
                
                var error: NSError?
                
                if self.asset.statusOfValue(forKey: trackKey, error: &error) == .failed {
                    print("failed: \(error!.localizedDescription)")
                    return
                }
                
                // We can't play this asset.
                if !self.asset.isPlayable || self.asset.hasProtectedContent {
                    print("not playable")
                    
                    return
                }
                
                /*
                 We can play this asset. Create a new AVPlayerItem and make it
                 our player's current item.
                 */
                self.playerItem = AVPlayerItem(asset: self.asset)
                self.player = AVPlayer(playerItem: self.playerItem)
                self.player.play()
            }
        }
    }
}
