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
        
        // Add drag and drop
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(draggedView(sender:)))
        playbackButtonView.addGestureRecognizer(panGestureRecognizer)
    
        addSwipeGestureTo(targetView: playbackButtonView, direction: .up)
        addSwipeGestureTo(targetView: playbackButtonView, direction: .down)
        addSwipeGestureTo(targetView: playbackButtonView, direction: .left)
        addSwipeGestureTo(targetView: playbackButtonView, direction: .right)
    
    }
    
    func addSwipeGestureTo(targetView: UIView, direction: UISwipeGestureRecognizerDirection) {
        let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeRecognizer(sender:)))
        swipeGestureRecognizer.direction = direction
        swipeGestureRecognizer.numberOfTouchesRequired = 1
        targetView.addGestureRecognizer(swipeGestureRecognizer)
    }
    
    // MARK: - UI Setup
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Pan and Swipe
    
    @objc func draggedView(sender:UIPanGestureRecognizer){
        if let _ = sender.view as? HPPlayerView {
            let translation = sender.translation(in: self.view)
            sender.setTranslation(CGPoint.zero, in: self.view)
            movePlayerByDeltaX(deltaX: translation.x, deltaY: translation.y)
        }
    }
    
    func movePlayerByDeltaX(deltaX: CGFloat, deltaY: CGFloat) {
        
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveLinear, animations: { [weak self] in
            
            self?.playbackButtonHorizontalConstraint.constant += deltaX
            self?.playbackButtonVerticalConstraint.constant += deltaY
            self?.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    func movePlayerVertical(targetY: CGFloat) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { [weak self] in
                        
                        self?.playbackButtonVerticalConstraint.constant = targetY
                        self?.view.layoutIfNeeded()
                        
                        
            }, completion: nil)
    }
    
    func movePlayerHorizontal(targetX: CGFloat) {
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { [weak self] in
                        
                        self?.playbackButtonHorizontalConstraint.constant = targetX
                        self?.view.layoutIfNeeded()
                        
                        
            }, completion: nil)
    }
    
    @objc func swipeRecognizer(sender: UISwipeGestureRecognizer) {
        
        let boundWidth = view.bounds.width
        let boundHeight = view.bounds.height
        let width = playbackButtonView.bounds.width
        let height = playbackButtonView.bounds.height
        
        if sender.direction == .up {
            let targetY = -((boundHeight * 0.5) - (height * 0.5))
            movePlayerVertical(targetY: targetY)
        }
        
        if sender.direction == .down {
            let targetY = (boundHeight * 0.5) - (height * 0.5)
            movePlayerVertical(targetY: targetY)
        }
        
        if sender.direction == .left {
            let targetX = -((boundWidth * 0.5) - (width * 0.5))
            movePlayerHorizontal(targetX: targetX)
        }
        
        if sender.direction == .right {
            let targetX = (boundWidth * 0.5) - (width * 0.5)
            movePlayerHorizontal(targetX: targetX)
        }
        
    }
}
