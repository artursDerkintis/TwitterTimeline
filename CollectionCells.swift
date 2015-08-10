//
//  CollectionCells.swift
//  TwitterTimeline
//
//  Created by Arturs Derkintis on 8/1/15.
//  Copyright © 2015 Starfly. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class SFTweetCell : UICollectionViewCell {
    
    var profileImageView : UIImageView?
    var profileLabel : UILabel?
    var profileUserLabel : UILabel?
    var tweetTextView : UITextView?
    var overlay : UIView?
    var imagesContainer : SFScrollView?
    var player : VideoPlayer?
    var needsVideoFrame = false
    var aspectRatio : [Int]?
    var time : SFSmartClock?
    var buttonFooter : UIStackView?
    var id : Int?
    var buttons  = [SFFButton]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.whiteColor()
        overlay = UIView(frame: bounds)
        overlay?.alpha = 0.08
        overlay?.autoresizingMask = sfMaskBoth
        addSubview(overlay!)
        overlay?.tag = 87874
        profileImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 50, height: 50))
        profileImageView?.layer.cornerRadius = 25.0
        profileImageView?.backgroundColor = UIColor.blackColor()
        profileImageView?.layer.masksToBounds = true
        profileImageView?.layer.borderWidth = 1
        addSubview(profileImageView!)
        profileLabel = UILabel(frame: CGRect(x: 70, y: 15, width: frame.width - 110, height: 25))
        profileLabel?.font = UIFont.systemFontOfSize(15, weight: UIFontWeightSemibold)
        profileLabel?.text = "User Name"
        profileLabel?.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        addSubview(profileLabel!)
        
        tweetTextView = UITextView(frame: CGRect(x: 65, y: 40, width: frame.width - 80, height: 0))
        
        tweetTextView?.font = UIFont.systemFontOfSize(17, weight: UIFontWeightRegular)
        tweetTextView?.text = ""
        tweetTextView?.scrollEnabled = false
        tweetTextView?.backgroundColor = .clearColor()
        tweetTextView?.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        addSubview(tweetTextView!)
        imagesContainer = SFScrollView(frame: CGRect(x: 10, y: 140, width: frame.width - 20 , height: 0))
        imagesContainer?.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        addSubview(imagesContainer!)
        player = VideoPlayer(frame: CGRect(x: 10, y: 140, width: frame.width - 20, height: 0))
        player?.backgroundColor = UIColor(rgba: "#aaaaaa")
        player?.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        addSubview(player!)
        
        buttonFooter = UIStackView(frame: CGRect(x: 0, y: frame.height - 50, width: frame.width, height: 50))
        buttonFooter?.backgroundColor = UIColor.clearColor()
        buttonFooter?.axis = UILayoutConstraintAxis.Horizontal
        buttonFooter?.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        buttonFooter?.distribution = UIStackViewDistribution.FillEqually
        let images = ["retweet", "fav"]
        for image in images {
            let button = SFFButton(type: UIButtonType.System)
            button.setImage(UIImage(named: image), forState: UIControlState.Normal)
            button.tintColor = UIColor.lightGrayColor()
            button.tag = images.indexOf(image)!
            buttonFooter!.addArrangedSubview(button)
            button.addTarget(self, action: "action:", forControlEvents: UIControlEvents.TouchUpInside)
            buttons.append(button)
        }
        
        addSubview(buttonFooter!)
        tweetTextView?.editable = false
        tweetTextView?.dataDetectorTypes = UIDataDetectorTypes.All
        layer.borderWidth = 1
        time = SFSmartClock(frame: CGRect(x: frame.width - 100, y: 15, width: 80, height: 25))
        time?.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin
        addSubview(time!)
    }
    func action(sender: SFFButton){
        if sender.tag == 0{
            TwitterClient.sharedInstance.retweetTweet(self.id!, params: nil, completion: { (error) -> () in
                print(error)
            })
            
        }else if sender.tag == 1{
            TwitterClient.sharedInstance.favoriteTweet(self.id!, params: nil, completion: { (error) -> () in
                print(error)
            })
        }
    }
    func playGif(gif : String, aspectRatioo : [Int]){
        if gif != ""{
            self.aspectRatio = aspectRatioo
            player!.URL = NSURL(string: gif)
            player!.endAction = VideoPlayerEndAction.Loop
            player?.volume = 0.0
            //player!.play()
            needsVideoFrame = true
            
        }else{
            removeGif()
            needsVideoFrame = false
    }
    
    }
    
    func removeGif(){
        if needsVideoFrame{
            
            player?.pause()
            
        }
    }
   
    func setImageWithURL(imgAddress: String) {
        let i = imgAddress.stringByReplacingOccurrencesOfString("normal", withString: "bigger")
        profileImageView!.setImageWithUrl(NSURL(string: i)!, placeHolderImage: placeholderPR)
    }
    func refreshImages(images : [String]?){
        imagesContainer!.releaseEverything()
        if images!.count > 0{
            imagesContainer?.setUp(SFCellSizeStyle.fixed, orien: SFOrienation.vertical, cellContentArray: images)
        }
    }
    func fakeImage(on on : Bool){
        imagesContainer?.containsSomething = on
    }
    func fakeGifPlayer(on on : Bool, aspectRatioo : [Int]){
        self.aspectRatio = aspectRatioo
        needsVideoFrame = on
    }
    func resize(){
        
        let fixedWidth = tweetTextView!.frame.size.width
        tweetTextView!.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        let newSize = tweetTextView!.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.max))
        var newFrame = tweetTextView!.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        tweetTextView!.frame = newFrame;
        buttonFooter?.frame = CGRect(x: 0, y: CGRectGetMaxY(tweetTextView!.frame) + 10, width: frame.width, height: 50)
        if imagesContainer!.containsSomething {
            imagesContainer?.frame = CGRect(x: 10, y: CGRectGetMaxY(tweetTextView!.frame) + 10, width: frame.width - 20, height: 280)
            buttonFooter?.frame = CGRect(x: 0, y: CGRectGetMaxY(imagesContainer!.frame) + 10, width: frame.width, height: 50)
            
        }else{
            imagesContainer?.frame = CGRect(x: 10, y: CGRectGetMaxY(tweetTextView!.frame) + 10, width: frame.width - 20, height: 0)
           
        }
        if needsVideoFrame{
            let widthRate : CGFloat = CGFloat(aspectRatio![0] as Int)
            let heightRate : CGFloat = CGFloat(aspectRatio![1] as Int)
            
            let height = (frame.width - 20) / widthRate * heightRate
            
            player!.frame = CGRect(x: 10, y:  CGRectGetMaxY(tweetTextView!.frame) + 10, width: frame.width - 20, height: height)
             player?.hidden = false
            player?.setNeedsLayout()
            buttonFooter?.frame = CGRect(x: 0, y: CGRectGetMaxY(player!.frame) + 10, width: frame.width, height: 50)
        }else{
            player!.frame = CGRect(x: 10, y:  CGRectGetMaxY(tweetTextView!.frame) + 10, width: frame.width - 20, height: 0)
            player?.hidden = true
            player?.setNeedsLayout()
        }
        
        frame.size = CGSize(width: frame.width, height: CGRectGetMaxY(buttonFooter!.frame))
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
public func randomInRange (lower: Int , upper: Int) -> Int {
    return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
}
public func randomString(len : Int) -> NSString {
    let s : NSString = "abcd efghijklmnopqrstu vwxyzABC DEFGHIJKLMNOPQRS TUVWXYZ0123456789"
    let mut : NSMutableString = NSMutableString(capacity: len)
    for var inde = 0; inde < len; ++inde {
        mut.appendFormat("%C", s.characterAtIndex(Int(arc4random_uniform(UInt32(s.length)))))
    }
    return mut.mutableCopy() as! NSString
}


class SFFButton : UIButton{
    var spacing : CGFloat = 6.0
    override func layoutSubviews() {
        super.layoutSubviews()
        imageEdgeInsets = UIEdgeInsetsZero
        titleEdgeInsets = UIEdgeInsetsZero
        imageView?.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        imageView?.center = CGPoint(x: frame.width * 0.5 - 10, y: frame.height * 0.5)
        titleLabel?.frame = CGRect(x: frame.width * 0.5 + 5, y: 0, width: frame.width, height: frame.height)
        titleLabel?.textAlignment = NSTextAlignment.Left
        titleLabel?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightRegular)
    }
  
    
    
    
    
}
