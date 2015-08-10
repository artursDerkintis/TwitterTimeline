
//
//  VideoPlayer.swift
//  TwitterTimeline
//
//  Created by Arturs Derkintis on 8/1/15.
//  Copyright © 2015 Starfly. All rights reserved.
//

import AVFoundation
import CoreMedia
import UIKit

protocol VideoPlayerDelegate {
    
    func videoPlayer(videoPlayer: VideoPlayer, changedState: VideoPlayerState)
    func videoPlayer(videoPlayer: VideoPlayer, encounteredError: NSError)
    
}

enum VideoPlayerEndAction: Int {
    
    case Stop = 1
    case Loop
    
}

enum VideoPlayerState: Int {
    
    case Stopped = 1
    case Loading, Playing, Paused
    
}

class VideoPlayer: UIView {
    
    // - Getters & Setters
    
    // Public
    
    var delegate : VideoPlayerDelegate?
    
    var endAction : VideoPlayerEndAction
    var state : VideoPlayerState {
        didSet {
            
          
            
        }
    }
    
    var URL : NSURL? {
        didSet {
            
            self.destroyPlayer()
            
        }
    }
    
    var volume : Float {
        didSet {
            
            if (self.player != nil) {
            
                self.player!.volume = self.volume
                
            }
            
        }
    }
    
    // Private
    
    var player : AVPlayer?
    var playerLayer : AVPlayerLayer?
    
    var actionButton : UIButton?
    
    var isBufferEmpty : Bool
    var isLoaded : Bool
    
    // - Initializing
    
    deinit {
        
        self.destroyPlayer()
        
    }

    override init(frame: CGRect) {
        
        self.endAction = VideoPlayerEndAction.Stop
        self.state = VideoPlayerState.Stopped;
        self.volume = 1.0;
        
        self.isBufferEmpty = false
        self.isLoaded = false
        
        super.init(frame: frame)
        let gesture = UITapGestureRecognizer(target: self, action: "pause")
        addGestureRecognizer(gesture)
        let actionButton : UIButton = UIButton(type: UIButtonType.Custom)
        actionButton.setImage(UIImage(named: "play"), forState: UIControlState.Normal)
        self.addSubview(actionButton)
        self.actionButton = actionButton
        self.actionButton!.addTarget(self, action: Selector("play"), forControlEvents: UIControlEvents.TouchUpInside)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // - Layout
    
    override func layoutSubviews() {
        
        self.actionButton!.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.actionButton!.center = CGPoint(x: self.bounds.width * 0.5, y: self.bounds.height * 0.5)
        
        if ((self.playerLayer) != nil) {
            self.playerLayer!.frame = self.bounds
            print(self.bounds.height)
        }
        bringSubviewToFront(self.actionButton!)
    }
    
    
    // - Setup Player
    
    
    func setupPlayer() {
        
        if !(self.URL != nil) {
            return;
        }
        
        self.destroyPlayer()
        
        let playerItem : AVPlayerItem = AVPlayerItem(URL: self.URL!)
        
        let player : AVPlayer = AVPlayer(playerItem: playerItem)
        player.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        player.volume = self.volume
        self.player = player;
        
        let playerLayer : AVPlayerLayer = AVPlayerLayer(player: player)
        self.layer.addSublayer(playerLayer)
        self.playerLayer = playerLayer
        
        player.play()
        
        self.addObservers()
        self.setNeedsLayout()

    }

    func destroyPlayer() {
        
        self.removeObservers();
        
        self.player = nil
        
        self.playerLayer?.removeFromSuperlayer()
        self.playerLayer = nil
        
        self.setStateNotifyingDelegate(VideoPlayerState.Stopped)
        
    }
    
    // - Player Notifications
    
    func playerFailed(notification: NSNotification) {
        
        self.destroyPlayer();
        self.delegate?.videoPlayer(self, encounteredError: NSError(domain: "VideoPlayer", code: 1, userInfo: [NSLocalizedDescriptionKey : "An unknown error occured."]))
        
    }
    
    func playerPlayedToEnd(notification: NSNotification) {
        
        switch self.endAction {
            
            case .Loop:
                
                self.player?.currentItem?.seekToTime(kCMTimeZero)
            
            case .Stop:
            
                self.destroyPlayer()
            
        }
        
    }
    
    // - Observers

    func addObservers() {

        self.player?.addObserver(self, forKeyPath: "rate", options: [], context: nil)
        
        self.player?.currentItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: [], context: nil)
        self.player?.currentItem?.addObserver(self, forKeyPath: "status", options: [], context: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerFailed:"), name: AVPlayerItemFailedToPlayToEndTimeNotification, object: self.player?.currentItem)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("playerPlayedToEnd:"), name: AVPlayerItemDidPlayToEndTimeNotification, object: self.player?.currentItem)
        
    }

    func removeObservers() {

        self.player?.removeObserver(self, forKeyPath: "rate")
        
        self.player?.currentItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
        self.player?.currentItem?.removeObserver(self, forKeyPath: "status")
        
        NSNotificationCenter.defaultCenter().removeObserver(self)

    }

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
    

        let obj = object as? NSObject
        if obj == self.player {
            
            if keyPath == "rate" {
                
                let rate = self.player?.rate
                if !self.isLoaded {
                    
                    self.setStateNotifyingDelegate(VideoPlayerState.Loading)
                    
                } else if rate == 1.0 {
                    
                    self.setStateNotifyingDelegate(VideoPlayerState.Playing)
                    
                } else if rate == 0.0 {
                    
                    if self.isBufferEmpty {
                        
                        self.setStateNotifyingDelegate(VideoPlayerState.Loading)
                        
                    } else {
                        
                        self.setStateNotifyingDelegate(VideoPlayerState.Paused)
                        
                    }
                    
                }
                
            }
            
        } else if obj == self.player?.currentItem {
            
            if keyPath == "status" {
                
                let status : AVPlayerItemStatus? = self.player?.currentItem?.status
                if status == AVPlayerItemStatus.Failed {
                    
                    self.destroyPlayer()
                    self.delegate?.videoPlayer(self, encounteredError: NSError(domain: "VideoPlayer", code: 1, userInfo: [NSLocalizedDescriptionKey : "An unknown error occured."]))
                    
                } else if status == AVPlayerItemStatus.ReadyToPlay {
                    
                    self.isLoaded = true
                    self.setStateNotifyingDelegate(VideoPlayerState.Playing)
                    
                }

            } else if keyPath == "playbackBufferEmpty" {

                let empty : Bool? = self.player?.currentItem?.playbackBufferEmpty
                if (empty != nil) {

                    self.isBufferEmpty = true

                } else {

                    self.isBufferEmpty = false
                    
                }
                
            }
            
        }

    }

    // - Actions

    func play() {

        switch self.state {

            case VideoPlayerState.Paused:
                
                actionButton?.hidden = true
                self.player?.play()

            case VideoPlayerState.Stopped:

                self.setupPlayer();
                actionButton?.hidden = true
            default:
                break

        }

    }

    func pause() {

        switch self.state {

            case VideoPlayerState.Playing, VideoPlayerState.Loading:
                
                self.player?.pause()
             actionButton?.hidden = false
            default:
                break
            
        }
        
    }
    
    func stop() {
        
        if (self.state == VideoPlayerState.Stopped) {
            
            return
            
        }
        
        self.destroyPlayer()
        actionButton?.hidden = false
    }
    
    // - Getters & Setters
    
    func setStateNotifyingDelegate(state: VideoPlayerState) {
        
        self.state = state
        self.delegate?.videoPlayer(self, changedState: state)
        
    }

}
