//
//  ViewController.swift
//  Hip
//
//  Created by Suhendra Ahmad on 8/2/17.
//  Copyright © 2017 Ainasoft. All rights reserved.
//

import UIKit
import Pastel
import SnapKit

class ViewController: UIViewController {

    @IBOutlet weak var playbackButtonView: HPPlayerView!
    @IBOutlet weak var playbackButtonHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var playbackButtonVerticalConstraint: NSLayoutConstraint!
    
    var player: HPPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGradientBackground()
    
        player = HPPlayer(URL(string: "http://pubcache1.arkiva.de/test/hls_index.m3u8")!)
        
        playbackButtonView.player = player
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupGradientBackground() {
        let pastelView = PastelView()
        
        // Custom Direction
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        
        // Custom Duration
        pastelView.animationDuration = 10.0
        
        // Custom Color
        pastelView.setColors([UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),
                              UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
                              UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
                              UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0)])
        
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)
        
        pastelView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
