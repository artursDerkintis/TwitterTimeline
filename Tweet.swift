//
//  Tweet.swift
//  TwitterTimeline
//
//  Created by Arturs Derkintis on 8/1/15.
//  Copyright © 2015 Starfly. All rights reserved.
//
import UIKit

class Tweet: NSObject {
    var user: User?
    var id: Int?
    var text: String?
    var createdAtString: String?
    var createdAt: String?
    var favorite_count: Int?
    var favorited: Bool?
    var retweet_count: Int?
    var retweeted: Bool?
    var retweetedStatus : NSDictionary?
    var status = NSDictionary()
    var wholeUserName : NSAttributedString?
    var extendedE : ExtendedEntitie?
    var backUpDictionary : NSDictionary?
    init(dictionary: NSDictionary) {
        backUpDictionary = dictionary
        status = dictionary
        id = status["id"] as? Int
        let whoRT = "@" + (status.valueForKeyPath("user.screen_name") as! String)
        let rtStatus = status.valueForKey("retweeted_status") as? NSDictionary
        let inReply = status.valueForKey("in_reply_to_screen_name") as? NSObject
        
        let inRep = inReply is NSNull ? "" : "  in reply to @" + (inReply as! String)
        var rt = false
        if rtStatus != nil {
            rt = true
            status = rtStatus!
            
        }
        user = User(dictionary: status["user"] as! NSDictionary)
        let e = status["extended_entities"] as? NSDictionary
        if e != nil{
        extendedE = ExtendedEntitie(dictionary: e!)
        }
        text = status["text"] as? String
        createdAtString = status["created_at"] as? String
        favorite_count = status["favorite_count"] as? Int
        favorited = status["favorited"] as? Bool
        retweet_count = status["retweet_count"] as? Int
        retweeted = status["retweeted"] as? Bool
        
        
            ///Make on NSAttributedString to show Name|screenName|if replied to/retweeted by
            var whole : String?
            var attributedString : NSMutableAttributedString?
            if rt{
                whole = user!.name! + "  " + user!.screenname! + "  retweeted by " + whoRT
                attributedString = NSMutableAttributedString(string: whole!)
                let range = ((whole!) as NSString).rangeOfString(user!.screenname! + "  retweeted by " + whoRT)
                attributedString!.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14, weight: UIFontWeightRegular), range: range)
            }
            if inRep != ""{
                whole = user!.name! + "  " + user!.screenname! + inRep
                attributedString = NSMutableAttributedString(string: whole!)
                let range = ((whole!) as NSString).rangeOfString(user!.screenname! + inRep)
                attributedString!.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14, weight: UIFontWeightRegular), range: range)
            }
            if !rt && inRep == ""{
                whole = user!.name! + "  " + user!.screenname!
                attributedString = NSMutableAttributedString(string: whole!)
                let range = ((whole!) as NSString).rangeOfString(user!.screenname!)
                attributedString!.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(14, weight: UIFontWeightRegular), range: range)
            }
            wholeUserName = attributedString
        
        
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        for dictionary in array{
            tweets.append(Tweet(dictionary: dictionary))
        }
        return tweets
    }
    
}
