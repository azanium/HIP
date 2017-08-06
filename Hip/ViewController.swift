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

    var player: HPPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        player = HPPlayer(URL(string: "http://pubcache1.arkiva.de/test/hls_index.m3u8")!)
        player.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func play() {
        
        if player.playerState == .playing || player.playerState == .paused {
            player.pauseOrPlay()
        }
        else {
            player.loadMedia()
        }
    }
}

extension ViewController : HPPlayerDelegate {
    
    func playerStreamProgress(finishedStream: Int, totalStreams: Int) {
        
    }
    
    func playerStreamLoaded(player: HPPlayer) {
        
    }
}
