//
//  User.swift
//  TwitterTimeline
//
//  Created by Arturs Derkintis on 8/1/15.
//  Copyright © 2015 Starfly. All rights reserved.
//

import UIKit

var _currentUser: User?
let currentUserKey = "CurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"


class User: NSObject {
    
    var name: String?
    var screenname: String?
    var profileImageURL: String?
    var tagline: String?
    var dictionary: NSDictionary
    var themeColor : UIColor?
    var themeColorString : String = "ffffff"
    var fullImageURL : String?
    init(dictionary: NSDictionary){
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenname = "@" + (dictionary["screen_name"] as! String)
        profileImageURL = dictionary["profile_image_url"] as? String
        fullImageURL = profileImageURL?.stringByReplacingOccurrencesOfString("_normal", withString: "")
        tagline = dictionary["description"] as? String
        themeColorString = dictionary["profile_link_color"] as! String
        themeColor = UIColor(rgba: "#\(themeColorString)")
    }
    
    func logout() {
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    }
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
                if data != nil {
                    do{
                    let dictionary = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    
                    _currentUser = User(dictionary: dictionary)}
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            if _currentUser != nil {
                do{
                let data = try! NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: NSJSONWritingOptions.PrettyPrinted)
                
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)}
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
}
