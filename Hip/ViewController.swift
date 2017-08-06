//
//  ViewController.swift
//  Hip
//
//  Created by Suhendra Ahmad on 8/2/17.
//  Copyright © 2017 Ainasoft. All rights reserved.
//

import UIKit
import M3U8Kit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let player = HPPlayer(URL(string: "http://pubcache1.arkiva.de/test/hls_index.m3u8")!)
        player.play()
        
        /*HPDownloadManager.shared.addDownload(URL(string: "http://1.com")!)
        HPDownloadManager.shared.addDownload(URL(string: "http://2.com")!)
        HPDownloadManager.shared.addDownload(URL(string: "http://3.com")!)
        HPDownloadManager.shared.addDownload(URL(string: "http://4.com")!)
        HPDownloadManager.shared.addDownload(URL(string: "http://5.com")!)
        HPDownloadManager.shared.addDownload(URL(string: "http://6.com")!)
        HPDownloadManager.shared.addDownload(URL(string: "http://7.com")!)
        HPDownloadManager.shared.addDownload(URL(string: "http://8.com")!)
        HPDownloadManager.shared.addDownload(URL(string: "http://9.com")!)
        HPDownloadManager.shared.addDownload(URL(string: "http://10.com")!)
        
        HPDownloadManager.shared.start({ (currentTask, totalTask) in
            
            print("Finished task \(currentTask) of \(totalTask)")
            
        }) { 
            
            print("====================== DONE =========================")
        }
        
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
