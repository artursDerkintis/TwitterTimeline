//
//  SFSmartMediaPlayer.swift
//  TwitterTimeline
//
//  Created by Arturs Derkintis on 8/1/15.
//  Copyright © 2015 Starfly. All rights reserved.
//

import UIKit

class SFSmartClock: UIView {
    var label : UILabel?
    var timer : NSTimer?
    var createdAtString : String?
    override init(frame: CGRect) {
        super.init(frame: frame)
        label = UILabel(frame: self.bounds)
        label?.textAlignment = NSTextAlignment.Right
        label?.text = ""
        label?.font = UIFont.systemFontOfSize(14, weight: UIFontWeightRegular)
        label?.textColor = UIColor.blackColor()
        addSubview(label!)
        timer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "updateTime", userInfo: nil, repeats: true)
        updateTime()
    }
    func updateTime(){
       
        if createdAtString != nil{
        label?.text = dateFormater.dateFromString(createdAtString!)?.timeAgoSimple
        }
    }
    deinit{
        timer?.invalidate()
        timer = nil
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

 

}
