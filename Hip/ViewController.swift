//
//  ViewController.swift
//  Hip
//
//  Created by Suhendra Ahmad on 8/2/17.
//  Copyright © 2017 Ainasoft. All rights reserved.
//

import UIKit
import M3U8Kit
import AVFoundation
import GCDWebServer

class ViewController: UIViewController {

    var asset: AVURLAsset!
    var playerItem: AVPlayerItem!
    var player: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let docUrl = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask)[0]
        print("=> \(docUrl.path)")
        
        let player = HPPlayer(URL(string: "http://pubcache1.arkiva.de/test/hls_index.m3u8")!)
        player.delegate = self
        player.play()
        
        let webServer = GCDWebServer()
        webServer.addGETHandler(forBasePath: "/", directoryPath: docUrl.path, indexFilename: nil, cacheAge: 0, allowRangeRequests: true)
        webServer.start(withPort: 8080, bonjourName: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController : HPPlayerDelegate {

    func playerProgress(currentTask: Int, totalTask: Int) {
        
    }
    
    func playerAudioDownloaded(mediaPlaylist: String) {
        
        let url = URL(string: "http://127.0.0.1:8080/\(mediaPlaylist)")!
        
        
        
        print("play: \(url.path)")
        
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
