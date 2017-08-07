//
//  HPPlayerView.swift
//  Hip
//
//  Created by Suhendra Ahmad on 8/7/17.
//  Copyright © 2017 Ainasoft. All rights reserved.
//

import UIKit

class HPPlayerView: UIView {

    fileprivate let circlePathLayer = CAShapeLayer()
    var playbackButton: PlaybackButton!
    
    fileprivate var _player: HPPlayer?
    var player: HPPlayer? {
        get {
            return _player
        }
        set {
            _player = newValue
            _player?.delegate = self
        }
    }
    
    var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            if newValue > 1 {
                circlePathLayer.strokeEnd = 1
            }
            else if newValue < 0 {
                circlePathLayer.strokeEnd = 0
            }
            else {
                circlePathLayer.strokeEnd = newValue
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    fileprivate func setupView() {
        
        self.backgroundColor = UIColor.clear
        
        setupPlaybackButton()
        
        setupSpinner()
        
        progress = 0.0
    }
    
    fileprivate func setupSpinner() {
        circlePathLayer.fillColor = UIColor.clear.cgColor
        circlePathLayer.strokeColor = UIColor(hex: "42a5f5", alpha: 1.0).cgColor
        circlePathLayer.frame = bounds
        circlePathLayer.lineWidth = 4
        layer.addSublayer(circlePathLayer)
    }
    
    fileprivate func setupPlaybackButton() {
        playbackButton = PlaybackButton(frame: bounds)
        playbackButton.backgroundColor = UIColor(hex: "a0a0a0", alpha: 0.7)
        playbackButton.layer.cornerRadius = playbackButton.frame.size.height / 2
        playbackButton.layer.borderWidth = 5
        playbackButton.layer.borderColor = UIColor.clear.cgColor//(hex: "a0a0a0", alpha: 0.7).cgColor
        playbackButton.adjustMargin = 1
        playbackButton.contentEdgeInsets = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        playbackButton.duration = 0.4
        playbackButton.setButtonColor(UIColor(hex: "ffffff", alpha: 1.0))
        playbackButton.setButtonColor(UIColor(hex: "95a5a6", alpha: 1.0), buttonState: PlaybackButtonState.pending)
        playbackButton.setButtonState(.pending, animated: true)
        playbackButton.addTarget(self, action: #selector(playbackAction(sender:)), for: UIControlEvents.touchUpInside)
        
        addSubview(playbackButton)
    }
    
    fileprivate func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
        circleFrame.origin.x = circlePathLayer.bounds.midX - circleFrame.midX
        circleFrame.origin.y = circlePathLayer.bounds.midY - circleFrame.midY
        return circleFrame
    }
    
    fileprivate func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        circlePathLayer.frame = bounds
        circlePathLayer.path = circlePath().cgPath
    }
    
    // MARK: - Events
    
    @objc fileprivate func playbackAction(sender: AnyObject) {
        
        if playbackButton.buttonState == .playing {
            
            self.playbackButton.setButtonState(.pausing, animated: true)
            self._player?.pauseOrPlay()
            
        } else if playbackButton.buttonState == .pausing {
            
            self.playbackButton.setButtonState(.playing, animated: true)
            self._player?.pauseOrPlay()
            
        }
        else if playbackButton.buttonState == .pending {
            
            self._player?.loadMedia()
            
        }
    
    }
}

extension HPPlayerView : HPPlayerDelegate {
    
    func playerStreamProgress(finishedStream: Int, totalStreams: Int) {
        self.progress = CGFloat(finishedStream) / CGFloat(totalStreams)
    }
    
    func playerStreamLoaded(player: HPPlayer) {
        
        self.playbackButton.setButtonState(.pausing, animated: true)
        circlePathLayer.isHidden = true
    }
    
    func playerPlayEnded(player: HPPlayer) {
        
        self.playbackButton.setButtonState(.pending, animated: true)
        circlePathLayer.isHidden = false
        progress = 0
        
    }
}
