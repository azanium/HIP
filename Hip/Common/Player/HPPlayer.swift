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
    func playerStreamLoaded(player: HPPlayer)
    
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
    
    fileprivate var mediaPlaylist: String = ""
    fileprivate var audioFile: String = ""
    
    // MARK: - Init
    
    init(_ url: URL) {
        self.url = url
        
        // Spawn a web server to serve audio to the client
        setupWebServer()
        
        streamer = HPStreamer(url)
        
        NotificationCenter.default.addObserver(self, selector: #selector(mediaPlayEnded), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Methods
    
    func setupWebServer() {
        let docUrl = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)[0]
        
        webServer.addGETHandler(forBasePath: "/", directoryPath: docUrl.path, indexFilename: nil, cacheAge: 0, allowRangeRequests: true)
        webServer.start(withPort: 8080, bonjourName: nil)
    }
    
    func loadMedia() {
        
        if _playerState == .uninitialized || _playerState == .completed {
            _playerState = .fetching
            streamer.loadAsync(self)
        }
        
    }
    
    @objc fileprivate func mediaPlayEnded() {
        print("Media Player ended")
        player = nil
        asset = nil
        playerItem = nil
        _playerState = .completed
    }
    
    func pauseOrPlay() {
        if _playerState == .playing {
            _playerState = .paused
            player.pause()
        }
        else {
            _playerState = .playing
            player.play()
        }
    }
}

extension HPPlayer : HPStreamerDelegate {
    
    func streamerProgress(currentTask: Int, totalTask: Int) {
        self.delegate?.playerStreamProgress(finishedStream: currentTask, totalStreams: totalTask)
    }
    
    func streamerAudioDownloaded(mediaPlaylist: String, audioFile: String) {
        self.mediaPlaylist = mediaPlaylist
        self.audioFile = audioFile
        
        setupPlayer(mediaPlaylist: mediaPlaylist)
    }
    
    func setupPlayer(mediaPlaylist: String) {
        let url = URL(string: "http://127.0.0.1:8080/\(mediaPlaylist)")!
        
        print("# Play: \(url.path)")
        
        asset = AVURLAsset(url: url, options: nil)
        let trackKey = "tracks"
        
        asset.loadValuesAsynchronously(forKeys: [trackKey]) {
            
            DispatchQueue.main.async() {
                
                var error: NSError?
                
                if self.asset.statusOfValue(forKey: trackKey, error: &error) == .failed {
                    print("* Stream load failed: \(error!.localizedDescription)")
                    return
                }
                
                // We can't play this asset.
                if !self.asset.isPlayable || self.asset.hasProtectedContent {
                    print("* Stream not playable")
                    
                    return
                }
                
                /*
                 We can play this asset. Create a new AVPlayerItem and make it
                 our player's current item.
                 */
                self.playerItem = AVPlayerItem(asset: self.asset)
                self.player = AVPlayer(playerItem: self.playerItem)
                self.player.play()
                
                self._playerState = .playing
                
                self.delegate?.playerStreamLoaded(player: self)
            }
        }
    }
}
